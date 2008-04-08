From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [RFC][PATCH] another swap controller for cgroup
Date: Tue,  8 Apr 2008 12:29:37 +0900 (JST)
Message-ID: <20080408032937.3CCCE5A07@siro.lan>
References: <47ECB3B1.6040500@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Fri, 28 Mar 2008 18:00:33 +0900"
	<47ECB3B1.6040500-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org
Cc: minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: linux-mm.kvack.org

> YAMAMOTO Takashi wrote:
> > hi,
> > 
> > i tried to reproduce the large swap cache issue, but no luck.
> > can you provide a little more detailed instruction?
> > 
> This issue also happens on generic 2.6.25-rc3-mm1
> (with limitting only memory), so I think this issue is not
> related to your patch.
> I'm investigating this issue too.
> 
> Below is my environment and how to reproduce.
> 
> - System
>   full virtualized xen guest based on RHEL5.1(x86_64).
>     CPU: 2
>     memory: 2GB
>     swap: 1GB
>   A config of the running kernel(2.6.25-rc3-mm1 with your patch)
>   is attached.
> 
> - how to reproduce
>   - change swappines to 100
> 
>     echo 100 >/proc/sys/vm/swappiness
> 
>   - mount cgroup fs
> 
>     # mount -t cgroup -o memory,swap none /cgroup
> 
>   - make cgroup for test
> 
>     # mkdir /cgroup/02
>     # echo -n 64M >/cgroup/02/memory.limit_in_bytes
>     # echo -n `expr 128 \* 1024 \* 1024` >/cgroup/02/swap.limit_in_bytes
> 
>   - run test
> 
>     # echo $$ >/cgropu/02/tasks
>     # while true; do make clean; make -j2; done
> 
>   In other terminals, I run some monitoring processes, top,
>   "tail -f /var/log/messages", and displaying *.usage_in_bytes
>   every seconds.
> 
> 
> Thanks,
> Daisuke Nishimura.

what i tried was essentially same.
for me, once vm_swap_full() got true, swap cache stopped growing as expected.

	http://people.valinux.co.jp/~yamamoto/swap.png

it was taken by running
	while :;do swapon -s|tail -1;sleep 1;done > foo
in an unlimited cgroup, and then plotted by gnuplot.
	plot "foo" u 4

as my system has 1GB swap configured, the vm_swap_full() threshold is
around 500MB.

YAMAMOTO Takashi
