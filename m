Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 584FA6B5812
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 07:02:03 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id p12so3842449wrt.17
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 04:02:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i6sor3459660wru.21.2018.11.30.04.02.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Nov 2018 04:02:01 -0800 (PST)
MIME-Version: 1.0
References: <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz> <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz> <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz> <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz> <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz> <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz> <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
 <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com> <3173eba8-8d7a-b9d7-7d23-38e6008ce2d6@suse.cz>
In-Reply-To: <3173eba8-8d7a-b9d7-7d23-38e6008ce2d6@suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Fri, 30 Nov 2018 13:01:49 +0100
Message-ID: <CADF2uSre7NPvKuEN-Lx5sQ3TzwRuZiupf6kxs0WnFgV5u9z+Jg@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

Am Fr., 2. Nov. 2018 um 15:59 Uhr schrieb Vlastimil Babka <vbabka@suse.cz>:
>
> Forgot to answer this:
>
> On 10/31/18 3:53 PM, Marinko Catovic wrote:
> > Well caching of any operations with find/du is not necessary imho
> > anyway, since walking over all these millions of files in that time
> > period is really not worth caching at all - if there is a way you
> > mentioned to limit the commands there, that would be great.
> > Also I want to mention that these operations were in use with 3.x
> > kernels as well, for years, with absolutely zero issues.
>
> Yep, something had to change at some point. Possibly the
> reclaim/compaction loop. Probably not the way dentries/inodes are being
> cached though.
>
> > 2 > drop_caches right after that is something I considered, I just had
> > some bad experience with this, since I tried it around 5:00 AM in the
> > first place to give it enough spare time to finish, since sync; echo 2
> >> drop_caches can take some time, hence my question about lowering the
> > limits in mm/vmscan.c, void drop_slab_node(int nid)
> >
> > I could do this effectively right after find/du at 07:45, just hoping
> > that this is finished soon enough - in one worst case it took over 2
> > hours (from 05:00 AM to 07:00 AM), since the host was busy during that
> > time with find/du, never having freed enough caches to continue, hence
>
> Dropping caches while find/du is still running would be
> counter-productive. If done after it's already finished, it shouldn't be
> so disruptive.
>
> > my question to let it stop earlier with the modification of
> > drop_slab_node ... it was just an idea, nevermind if you believe that
> > it was a bad one :)
>
> Finding a universally "correct" threshold could easily be impossible. I
> guess the proper solution would be to drop the while loop and
> restructure the shrinking so that it would do a single pass through all
> objects.

well after a few weeks to make sure, the results seem very promising.
There were no issues any more after setting up the cgroup with the limit.

This workaround is anyway a good idea to prevent the nightly processed
from eating up all the caching/buffers which become useless anyway in
the morning, so performance got even better - although the issue is
not fixed with that workaround.
Since other people will be affected sooner or later as well imho,
hopefully you'll figure out a fix soon.

Nevertheless I also ran into a new problem there.
While writing the PID into the tasks-file (echo $$ > ../tasks) or a
direct fputs(getpid(), tasks_fp);
works very well, I also had problems with daemons that I wanted to
start (e.g. a SQL server) from within that cgroup-controlled binary.
This results in the sql server's task kill, since the memory limit is
exceeded. I would not like to set the memory.limit_in_bytes to
something that huge, such as 30G to make sure, I'd rather just use a
wrapper script to handle this, for example:
1) the cgroup-controlled instance starts the wrapper script
2) which excludes itself from the tasks-PID-list (hence the wrapper
script it is not controlled any more)
3) it starts or does whatever necessary that should continue normally
without the memory restriction

Currently I fail to manage this, since I do not know how to do step 2.
echo $PID > tasks writes into it and adds the PID, but how would one
remove the wrapper script's PID from there?
I came up with: cat /cgpath/A/tasks | sed "/$$/d" | cat >
/cgpath/A/tasks ..which results in a list without the current PID,
however, it fails to write to tasks with cat: write error: Invalid
argument, since this is not a regular file.
