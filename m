Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 895C66B0033
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 05:49:36 -0400 (EDT)
Date: Tue, 11 Jun 2013 11:49:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM Killer and add_to_page_cache_locked
Message-ID: <20130611094934.GE24031@dhcp22.suse.cz>
References: <51B05616.9050501@adocean-global.com>
 <20130606155323.GD24115@dhcp22.suse.cz>
 <51B1F8B3.8030108@adocean-global.com>
 <20130607153635.GJ8117@dhcp22.suse.cz>
 <51B6E135.2020409@adocean-global.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51B6E135.2020409@adocean-global.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Nowojski <piotr.nowojski@adocean-global.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 11-06-13 10:35:01, Piotr Nowojski wrote:
> W dniu 07.06.2013 17:36, Michal Hocko pisze:
> >On Fri 07-06-13 17:13:55, Piotr Nowojski wrote:
> >>W dniu 06.06.2013 17:57, Michal Hocko pisze:
> >>>>>In our system we have hit some very annoying situation (bug?) with
> >>>>>cgroups. I'm writing to you, because I have found your posts on
> >>>>>mailing lists with similar topic. Maybe you could help us or point
> >>>>>some direction where to look for/ask.
> >>>>>
> >>>>>We have system with ~15GB RAM (+2GB SWAP), and we are running ~10
> >>>>>heavy IO processes. Each process is using constantly 200-210MB RAM
> >>>>>(RSS) and a lot of page cache. All processes are in cgroup with
> >>>>>following limits:
> >>>>>
> >>>>>/sys/fs/cgroup/taskell2 $ cat memory.limit_in_bytes
> >>>>>memory.memsw.limit_in_bytes
> >>>>>14183038976
> >>>>>15601344512
> >>>I assume that memory.use_hierarchy is 1, right?
> >>System has been rebooted since last test, so I can not guarantee
> >>that it was set for 100%, but it should have been. Currently I'm
> >>rerunning this scenario that lead to the described problem with:
> >>
> >>/sys/fs/cgroup/taskell2# cat memory.use_hierarchy ../memory.use_hierarchy
> >>1
> >>0
> >OK, good. Your numbers suggeste that the hierachy _is_ in use. I just
> >wanted to be 100% sure.
> >
> 
> I don't know what has solved this problem, but we weren't able to
> reproduce this problem during whole weekend. Most likely there was
> some problem with our code initializing cgroups configuration
> regarding use_hierarchy (can writing 1 to memory.use_hierarchy
> silently fail?).

No it complains with EINVAL or EBUSY but maybe you have tripped over
bash built-in echo which doesn't return error codes properly AFAIR.
Always make sure you use /bin/echo. If you are doing initialization in
parallel then this in-deed might race and use_hierarchy fail to set to 1
if any children have been created in the mean time.
But again, your numbers suggested that the parent group collected
charges from children so this would be rather unexpected.

> I have added assertions for checking this parameter before starting
> and after initialization of our application. If problem reoccur, I
> will proceed as you suggested before - trying latest kernels.
> 
> Thanks, Piotr Nowojski

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
