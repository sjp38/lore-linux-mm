Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0546B0007
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:54:05 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id h67-v6so14412882wmh.0
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 07:54:05 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 3-v6sor5434194wmd.3.2018.10.31.07.53.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 07:53:57 -0700 (PDT)
MIME-Version: 1.0
References: <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz> <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz> <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz> <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz> <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz> <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz> <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
In-Reply-To: <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Wed, 31 Oct 2018 15:53:44 +0100
Message-ID: <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

> I went through the whole thread again as it was spread over months, and
> finally connected some dots. In one mail you said:
>
> > There is one thing I forgot to mention: the hosts perform find and du (I mean the commands, finding files and disk usage)
> > on the HDDs every night, starting from 00:20 AM up until in the morning 07:45 AM, for maintenance and stats.
>
> The timespan above roughly matches the phase where reclaimable slab grow
> (samples 2000-6000 over 5 seconds is roughly 5.5 hours). The find will
> fetch a lots of metadata in dentries, inodes etc. which are part of
> reclaimable slabs. In other mail you posted a slabinfo
> https://pastebin.com/81QAFgke in the phase where it's already being
> slowly reclaimed, but still occupies 6.5GB, and mostly it's
> ext4_inode_cache, and dentry cache (also very much internally fragmented).
> In another mail I suggest that maybe fragmentation happened because the
> slab filled up much more at some point, and I think we now have that
> solidly confirmed from the vmstat plots.
> I think one workaround is for you to perform echo 2 > drop_caches (not
> 3) right after the find/du maintenance finishes. At that point you don't
> have too much page cache anyway, since the slabs have pushed it out.
> It's also overnight so there are not many users yet?
> Alternatively the find/du could run in a memcg limiting its slab use.
> Michal would know the details.
>
> Long term we should do something about these slab objects that are only
> used briefly (once?) so there's no point in caching them and letting the
> cache grow like this.
>

Well caching of any operations with find/du is not necessary imho
anyway, since walking over all these millions of files in that time
period is really not worth caching at all - if there is a way you
mentioned to limit the commands there, that would be great.
Also I want to mention that these operations were in use with 3.x
kernels as well, for years, with absolutely zero issues.

2 > drop_caches right after that is something I considered, I just had
some bad experience with this, since I tried it around 5:00 AM in the
first place to give it enough spare time to finish, since sync; echo 2
> drop_caches can take some time, hence my question about lowering the
limits in mm/vmscan.c, void drop_slab_node(int nid)

I could do this effectively right after find/du at 07:45, just hoping
that this is finished soon enough - in one worst case it took over 2
hours (from 05:00 AM to 07:00 AM), since the host was busy during that
time with find/du, never having freed enough caches to continue, hence
my question to let it stop earlier with the modification of
drop_slab_node ... it was just an idea, nevermind if you believe that
it was a bad one :)
