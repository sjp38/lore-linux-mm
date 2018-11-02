Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7770E6B0006
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 04:05:16 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d17-v6so801001edv.4
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 01:05:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3-v6si7539054eja.205.2018.11.02.01.05.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 01:05:15 -0700 (PDT)
Date: Fri, 2 Nov 2018 09:05:13 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20181102080513.GB5564@dhcp22.suse.cz>
References: <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz>
 <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
 <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
 <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
 <20181031170108.GR32673@dhcp22.suse.cz>
 <CADF2uSpE9=iS5_KwPDRCuBECE+Kp5i5yDn3Vz8A+SxGTQ=DC3Q@mail.gmail.com>
 <20181101132307.GJ23921@dhcp22.suse.cz>
 <CADF2uSqO8+_uZA5qHjWJ08UOqqH6C_d-_R+9qAAbxw5sdTYSMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSqO8+_uZA5qHjWJ08UOqqH6C_d-_R+9qAAbxw5sdTYSMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

On Thu 01-11-18 23:46:27, Marinko Catovic wrote:
> Am Do., 1. Nov. 2018 um 14:23 Uhr schrieb Michal Hocko <mhocko@suse.com>:
> >
> > On Wed 31-10-18 20:21:42, Marinko Catovic wrote:
> > > Am Mi., 31. Okt. 2018 um 18:01 Uhr schrieb Michal Hocko <mhocko@suse.com>:
> > > >
> > > > On Wed 31-10-18 15:53:44, Marinko Catovic wrote:
> > > > [...]
> > > > > Well caching of any operations with find/du is not necessary imho
> > > > > anyway, since walking over all these millions of files in that time
> > > > > period is really not worth caching at all - if there is a way you
> > > > > mentioned to limit the commands there, that would be great.
> > > >
> > > > One possible way would be to run this find/du workload inside a memory
> > > > cgroup with high limit set to something reasonable (that will likely
> > > > require some tuning). I am not 100% sure that will behave for metadata
> > > > mostly workload without almost any pagecache to reclaim so it might turn
> > > > out this will result in other issues. But it is definitely worth trying.
> > >
> > > hm, how would that be possible..? every user has its UID, the group
> > > can also not be a factor, since this memory restriction would apply to
> > > all users then, find/du are running as UID 0 to have access to
> > > everyone's data.
> >
> > I thought you have a dedicated script(s) to do all the stats. All you
> > need is to run that particular script(s) within a memory cgroup
> 
> yes, that is the case - the scripts are running as root, since as
> mentioned all users have own UIDs and specific groups, so to have
> access one would need root privileges.
> My question was how to limit this using cgroups, since afaik limits
> there apply to given UIDs/GIDs

No. Limits apply to a specific memory cgroup and all tasks which are
associated with it. There are many tutorials on how to configure/use
memory cgroups or cgroups in general. If I were you I would simply do
this

mount -t cgroup -o memory none $SOME_MOUNTPOINT
mkdir $SOME_MOUNTPOINT/A
echo 500M > $SOME_MOUNTPOINT/A/memory.limit_in_bytes

Your script then just do
echo $$ > $SOME_MOUNTPOINT/A/tasks
# rest of your script
echo 1 > $SOME_MOUNTPOINT/A/memory.force_empty

That should drop the memory cached on behalf of the memcg A including the
metadata.


[...]
> > > As I understand everyone would have this issue when extensive walking
> > > over files is performed, basically any `cloud`, shared hosting or
> > > storage systems should experience it, true?
> >
> > Not really. You need also a high demand for high order allocations to
> > require contiguous physical memory. Maybe there is something in your
> > workload triggering this particular pattern.
> 
> I would not even know what triggers it, nor what it has to do with
> high order, I'm just running find/du, nothing special I'd say.

Please note that find/du is mostly a fragmentation generator. It
seems there is other system activity which requires those high order
allocations.
-- 
Michal Hocko
SUSE Labs
