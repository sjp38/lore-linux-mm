Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4F836B0266
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 10:59:04 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y72-v6so1273469ede.22
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 07:59:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a22-v6si32582eje.78.2018.11.02.07.59.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 07:59:03 -0700 (PDT)
Subject: Re: Caching/buffers become useless after some time
References: <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz>
 <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz>
 <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz>
 <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz>
 <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz>
 <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
 <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
 <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3173eba8-8d7a-b9d7-7d23-38e6008ce2d6@suse.cz>
Date: Fri, 2 Nov 2018 15:59:02 +0100
MIME-Version: 1.0
In-Reply-To: <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

Forgot to answer this:

On 10/31/18 3:53 PM, Marinko Catovic wrote:
> Well caching of any operations with find/du is not necessary imho
> anyway, since walking over all these millions of files in that time
> period is really not worth caching at all - if there is a way you
> mentioned to limit the commands there, that would be great.
> Also I want to mention that these operations were in use with 3.x
> kernels as well, for years, with absolutely zero issues.

Yep, something had to change at some point. Possibly the
reclaim/compaction loop. Probably not the way dentries/inodes are being
cached though.

> 2 > drop_caches right after that is something I considered, I just had
> some bad experience with this, since I tried it around 5:00 AM in the
> first place to give it enough spare time to finish, since sync; echo 2
>> drop_caches can take some time, hence my question about lowering the
> limits in mm/vmscan.c, void drop_slab_node(int nid)
> 
> I could do this effectively right after find/du at 07:45, just hoping
> that this is finished soon enough - in one worst case it took over 2
> hours (from 05:00 AM to 07:00 AM), since the host was busy during that
> time with find/du, never having freed enough caches to continue, hence

Dropping caches while find/du is still running would be
counter-productive. If done after it's already finished, it shouldn't be
so disruptive.

> my question to let it stop earlier with the modification of
> drop_slab_node ... it was just an idea, nevermind if you believe that
> it was a bad one :)

Finding a universally "correct" threshold could easily be impossible. I
guess the proper solution would be to drop the while loop and
restructure the shrinking so that it would do a single pass through all
objects.
