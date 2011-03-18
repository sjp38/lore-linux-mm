Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8648D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 11:25:39 -0400 (EDT)
Date: Fri, 18 Mar 2011 16:25:32 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: cgroup: real meaning of memory.usage_in_bytes
Message-ID: <20110318152532.GB18450@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Kame,

I have received a report that our SLE11-SP1 (based on 2.6.32) kernel
doesn't pass LTP cgroup test case[*]. The test case basically creates a
cgroup (with 100M), runs a simple allocator which dirties a certain
amount of anonymous memory (under the limit) and finally checks whether
memory.usage_in_bytes == memory.stat (rss value).

This is obviously not 100% correct as the test should consider also
cache size but this test case doesn't end up using any cache pages so it
used worked when it was developed.

According to our documention this is a reasonable test case:
Documentation/cgroups/memory.txt:
memory.usage_in_bytes           # show current memory(RSS+Cache) usage.

This however doesn't work after your commit:
cdec2e4265d (memcg: coalesce charging via percpu storage)

because since then we are charging in bulks so we can end up with
rss+cache <= usage_in_bytes. Simple (attached) program will
show this as well:
# mkdir /dev/memctl; mount -t cgroup -omemory cgroup /dev/memctl; cd /dev/memctl
# mkdir group_1; cd group_1; echo 100M > memory.limit_in_bytes
# cat memory.{usage_in_bytes,stat} 
0
cache 0
rss 0
[...]

[run the program - it will print its pid and wait for enter]
echo pid > tasks

[hit enter to make the program mmap and dirty pages]
# cat memory.{usage_in_bytes,stat} 
131072
cache 0
rss 4096
[...]

[hit enter again to let it finish]
# cat memory.{usage_in_bytes,stat} 
126976
cache 0
rss 0
[...]

I think we have several options here
	1) document that the value is actually >= rss+cache and it shows
	   the guaranteed charges for the group
	2) use rss+cache rather then res->count
	3) remove the file
	4) call drain_all_stock_sync before asking for the value in
	   mem_cgroup_read
	5) collect the current amount of stock charges and subtract it
	   from the current res->count value

1) and 2) would suggest that the file is actually not very much useful.
3) is basically the interface change as well
4) sounds little bit invasive as we basically lose the advantage of the
pool whenever somebody reads the file. Btw. for who is this file
intended?
5) sounds like a compromise

As I do not see a point of the file I would like to get rid of it
completely rather than play games around it but I am not sure why we
have it in the first place.

What do you (and others) think? I have a patch for 4 ready here but I
would like to understand the purpose of the file more before I post it.

Thanks
--- 
[*] You can get source at http://sourceforge.net/projects/ltp/
./testcases/kernel/controllers/memctl/memctl_test01.c and
./testcases/kernel/controllers/memctl/run_memctl_test.sh

The test should be executed with 4 as the parameter
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
