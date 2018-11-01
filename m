Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A32FB6B0010
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 18:46:41 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id v6-v6so42054wri.23
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 15:46:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c12-v6sor9785511wrs.36.2018.11.01.15.46.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Nov 2018 15:46:40 -0700 (PDT)
MIME-Version: 1.0
References: <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz> <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz> <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
 <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
 <20181031170108.GR32673@dhcp22.suse.cz> <CADF2uSpE9=iS5_KwPDRCuBECE+Kp5i5yDn3Vz8A+SxGTQ=DC3Q@mail.gmail.com>
 <20181101132307.GJ23921@dhcp22.suse.cz>
In-Reply-To: <20181101132307.GJ23921@dhcp22.suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Thu, 1 Nov 2018 23:46:27 +0100
Message-ID: <CADF2uSqO8+_uZA5qHjWJ08UOqqH6C_d-_R+9qAAbxw5sdTYSMg@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

Am Do., 1. Nov. 2018 um 14:23 Uhr schrieb Michal Hocko <mhocko@suse.com>:
>
> On Wed 31-10-18 20:21:42, Marinko Catovic wrote:
> > Am Mi., 31. Okt. 2018 um 18:01 Uhr schrieb Michal Hocko <mhocko@suse.com>:
> > >
> > > On Wed 31-10-18 15:53:44, Marinko Catovic wrote:
> > > [...]
> > > > Well caching of any operations with find/du is not necessary imho
> > > > anyway, since walking over all these millions of files in that time
> > > > period is really not worth caching at all - if there is a way you
> > > > mentioned to limit the commands there, that would be great.
> > >
> > > One possible way would be to run this find/du workload inside a memory
> > > cgroup with high limit set to something reasonable (that will likely
> > > require some tuning). I am not 100% sure that will behave for metadata
> > > mostly workload without almost any pagecache to reclaim so it might turn
> > > out this will result in other issues. But it is definitely worth trying.
> >
> > hm, how would that be possible..? every user has its UID, the group
> > can also not be a factor, since this memory restriction would apply to
> > all users then, find/du are running as UID 0 to have access to
> > everyone's data.
>
> I thought you have a dedicated script(s) to do all the stats. All you
> need is to run that particular script(s) within a memory cgroup

yes, that is the case - the scripts are running as root, since as
mentioned all users have own UIDs and specific groups, so to have
access one would need root privileges.
My question was how to limit this using cgroups, since afaik limits
there apply to given UIDs/GIDs

> > so what is the conclusion from this issue now btw? is it something
> > that will be changed/fixed at any time?
>
> It is likely that you are triggering a pathological memory fragmentation
> with a lot of unmovable objects that prevent it to get resolved. That
> leads to memory over reclaim to make a forward progress. A hard nut to
> resolve but something that is definitely on radar to be solved
> eventually. So far we have been quite lucky to not trigger it that
> badly.

good to hear :)

> > As I understand everyone would have this issue when extensive walking
> > over files is performed, basically any `cloud`, shared hosting or
> > storage systems should experience it, true?
>
> Not really. You need also a high demand for high order allocations to
> require contiguous physical memory. Maybe there is something in your
> workload triggering this particular pattern.

I would not even know what triggers it, nor what it has to do with
high order, I'm just running find/du, nothing special I'd say.
