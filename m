Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 450266B0005
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 09:23:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x1-v6so12095064edh.8
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 06:23:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e26-v6si995470eda.117.2018.11.01.06.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 06:23:09 -0700 (PDT)
Date: Thu, 1 Nov 2018 14:23:07 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20181101132307.GJ23921@dhcp22.suse.cz>
References: <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz>
 <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
 <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
 <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
 <20181031170108.GR32673@dhcp22.suse.cz>
 <CADF2uSpE9=iS5_KwPDRCuBECE+Kp5i5yDn3Vz8A+SxGTQ=DC3Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSpE9=iS5_KwPDRCuBECE+Kp5i5yDn3Vz8A+SxGTQ=DC3Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

On Wed 31-10-18 20:21:42, Marinko Catovic wrote:
> Am Mi., 31. Okt. 2018 um 18:01 Uhr schrieb Michal Hocko <mhocko@suse.com>:
> >
> > On Wed 31-10-18 15:53:44, Marinko Catovic wrote:
> > [...]
> > > Well caching of any operations with find/du is not necessary imho
> > > anyway, since walking over all these millions of files in that time
> > > period is really not worth caching at all - if there is a way you
> > > mentioned to limit the commands there, that would be great.
> >
> > One possible way would be to run this find/du workload inside a memory
> > cgroup with high limit set to something reasonable (that will likely
> > require some tuning). I am not 100% sure that will behave for metadata
> > mostly workload without almost any pagecache to reclaim so it might turn
> > out this will result in other issues. But it is definitely worth trying.
> 
> hm, how would that be possible..? every user has its UID, the group
> can also not be a factor, since this memory restriction would apply to
> all users then, find/du are running as UID 0 to have access to
> everyone's data.

I thought you have a dedicated script(s) to do all the stats. All you
need is to run that particular script(s) within a memory cgroup
 
> so what is the conclusion from this issue now btw? is it something
> that will be changed/fixed at any time?

It is likely that you are triggering a pathological memory fragmentation
with a lot of unmovable objects that prevent it to get resolved. That
leads to memory over reclaim to make a forward progress. A hard nut to
resolve but something that is definitely on radar to be solved
eventually. So far we have been quite lucky to not trigger it that
badly.

> As I understand everyone would have this issue when extensive walking
> over files is performed, basically any `cloud`, shared hosting or
> storage systems should experience it, true?

Not really. You need also a high demand for high order allocations to
require contiguous physical memory. Maybe there is something in your
workload triggering this particular pattern.
-- 
Michal Hocko
SUSE Labs
