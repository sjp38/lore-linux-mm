Date: Fri, 17 Aug 2007 13:37:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00/23] per device dirty throttling -v9
In-Reply-To: <1187335158.6114.119.camel@twins>
Message-ID: <Pine.LNX.4.64.0708171333370.9404@schroedinger.engr.sgi.com>
References: <20070816074525.065850000@chello.nl>
 <Pine.LNX.4.64.0708161424010.18861@schroedinger.engr.sgi.com>
 <1187335158.6114.119.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 17 Aug 2007, Peter Zijlstra wrote:

> Currently we do: 
>   dirty = total_dirty * bdi_completions_p * task_dirty_p
> 
> As dgc pointed out before, there is the issue of bdi/task correlation,
> that is, we do not track task dirty rates per bdi, so now a task that
> heavily dirties on one bdi will also get penalised on the others (and
> similar issues).

I think that is tolerable.
> 
> If we were to change it so:
>   dirty = cpuset_dirty * bdi_completions_p * task_dirty_p
> 
> We get additional correlation issues: cpuset/bdi, cpuset/task.
> Which could yield surprising results if some bdis are strictly per
> cpuset.

If we do not do the above then the dirty page calculation for a small 
cpuset (F.e. 1 node of a 128 node system) could allow an amount of dirty
pages that will fill up all the node.

> The cpuset/task correlation has a strict mapping and could be solved by
> keeping the vm_dirties counter per cpuset. However, this would seriously
> complicate the code and I'm not sure if it would gain us much.

The patchset that I referred to has code to calculate the dirty count and 
ratio per cpuset by looping over the nodes. Currently we are having 
trouble with small cpusets not performing writeout correctly. This 
sometimes may result in OOM conditions because the whole node is full of 
dirty pages. If the cpu boundaries are enforced in a strict way then the 
application may fail with an OOM.

We can compensate by recalculating the dirty_ratio based on the smallest 
cpuset but then larger cpusets are penalized. Also one cannot set the 
dirty_ratio below a certain mininum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
