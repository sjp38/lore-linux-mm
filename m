Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id E004F6B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 15:45:04 -0500 (EST)
Date: Thu, 12 Jan 2012 21:44:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: add mlock statistic in memory.stat
Message-ID: <20120112204458.GA10389@tiehlicka.suse.cz>
References: <1326321668-5422-1-git-send-email-yinghan@google.com>
 <20120112125411.GG1042@tiehlicka.suse.cz>
 <CALWz4izcSeY3TvrBUurg+X_fyHn3EPGRRS_jvSr0c2CWDnuhAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4izcSeY3TvrBUurg+X_fyHn3EPGRRS_jvSr0c2CWDnuhAQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Thu 12-01-12 11:09:58, Ying Han wrote:
> On Thu, Jan 12, 2012 at 4:54 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Wed 11-01-12 14:41:08, Ying Han wrote:
> >> We have the nr_mlock stat both in meminfo as well as vmstat system wide, this
> >> patch adds the mlock field into per-memcg memory stat. The stat itself enhances
> >> the metrics exported by memcg, especially is used together with "uneivctable"
> >> lru stat.
> >
> > Could you describe when the unevictable has such a different meaning than
> > mlocked that it is unusable?
> 
> The unevictable lru includes more than mlock()'d pages ( SHM_LOCK'd
> etc). Like the following:

Yes, I am aware of that. Maybe I wasn't clear enough in my question. I
was rather interested _when_ it actually matters for your decisions about
the setup. Those pages are not evictable anyway.

> $ memtoy>shmem shm_400m 400m
> $ memtoy>map shm_400m 0 400m
> $ memtoy>touch shm_400m
> memtoy:  touched 102400 pages in  0.360 secs
> $ memtoy>slock shm_400m
> //meantime add some memory pressure.
> 
> $ memtoy>file /export/hda3/file_512m
> $ memtoy>map file_512m 0 512m shared
> $ memtoy>lock file_512m
> 
> $ cat /dev/cgroup/memory/B/memory.stat
> mapped_file 956301312
> mlock 536870912
> unevictable 956203008
> 
> Here, mapped_file - mlock = 400M shm_lock'ed pages are included in
> unevictable stat.
> 
> Besides, not all mlock'ed pages get to unevictable lru at the first
> place, and the same for the other way around.
> 
> Thanks
> 
> --Ying

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
