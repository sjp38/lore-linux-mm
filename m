Date: Fri, 23 May 2008 14:23:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] swapcgroup(v2)
Message-Id: <20080523142305.99c1972b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48364D38.7000304@linux.vnet.ibm.com>
References: <20080523121027.b0eecfa0.kamezawa.hiroyu@jp.fujitsu.com>
	<4836411B.2030601@linux.vnet.ibm.com>
	<20080523131812.84F1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<48364D38.7000304@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Fri, 23 May 2008 10:21:04 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KOSAKI Motohiro wrote:
> >> One option is to limit the virtual address space usage of the cgroup to ensure
> >> that swap usage of a cgroup will *not* exceed the specified limit. Along with a
> >> good swap controller, it should provide good control over the cgroup's memory usage.
> > 
> > unfortunately, it doesn't works in real world.
> > IMHO you said as old good age.
> > 
> > because, Some JavaVM consume crazy large virtual address space.
> > it often consume >10x than phycal memory consumption.
> > 
> 
> Have you seen any real world example of this? 
I have no objection to that virual-address-space limitation can work well on
well-controlled-system. But there are more complicated systems in chaos.

One example I know was that a team for the system tried to count all vm space
for setting vm.overcommit_memory to be proper value. The just found they can't
do it on a server with tens of applications after a month.

One of difficult problem is that a system administrator can't assume the total 
size of virtual address space of proprietary applications/library. 
An application designer can estimate "the virutal address usage of an application
is between XXM to XXXXM. but admin can't esitmate the total.

In above case, the most problematic user of virual adddress space was pthreads.
Default stack size of pthreads on ia64 was 10M bytes (--; And almost all application
doesn't answer how small they can set its stack size to. It's crazy to set this value
per applications.  Then, "stack" of 2000 threads requires 20G bytes of virtual
address space on 12G system ;) They failed to use overcommit.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
