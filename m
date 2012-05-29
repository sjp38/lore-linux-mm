Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 951946B006E
	for <linux-mm@kvack.org>; Tue, 29 May 2012 16:57:42 -0400 (EDT)
Received: by qabg27 with SMTP id g27so1843886qab.14
        for <linux-mm@kvack.org>; Tue, 29 May 2012 13:57:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205291514090.2504@router.home>
References: <1337951028-3427-1-git-send-email-glommer@parallels.com>
	<1337951028-3427-14-git-send-email-glommer@parallels.com>
	<alpine.DEB.2.00.1205290932530.4666@router.home>
	<4FC4F1A7.2010206@parallels.com>
	<alpine.DEB.2.00.1205291101580.6723@router.home>
	<4FC501E9.60607@parallels.com>
	<alpine.DEB.2.00.1205291222360.8495@router.home>
	<4FC506E6.8030108@parallels.com>
	<alpine.DEB.2.00.1205291424130.8495@router.home>
	<4FC52612.5060006@parallels.com>
	<alpine.DEB.2.00.1205291454030.2504@router.home>
	<4FC52CC6.7020109@parallels.com>
	<alpine.DEB.2.00.1205291514090.2504@router.home>
Date: Tue, 29 May 2012 13:57:41 -0700
Message-ID: <CABCjUKCPoL1+qzjX85RVGpRBn_javD3JY2avstYuoM=tsJa8dA@mail.gmail.com>
Subject: Re: [PATCH v3 13/28] slub: create duplicate cache
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

Hi Christoph,

On Tue, May 29, 2012 at 1:21 PM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 30 May 2012, Glauber Costa wrote:
>
>> Well, I'd have to dive in the code a bit more, but that the impression t=
hat
>> the documentation gives me, by saying:
>>
>> "Cpusets constrain the CPU and Memory placement of tasks to only
>> the resources within a task's current cpuset."
>>
>> is that you can't allocate from a node outside that set. Is this correct=
?
>
> Basically yes but there are exceptions (like slab queues etc). Look at th=
e
> hardwall stuff too that allows more exceptions for kernel allocations to
> use memory from other nodes.
>
>> So extrapolating this to memcg, the situation is as follows:
>>
>> * You can't use more memory than what you are assigned to.
>> * In order to do that, you need to account the memory you are using
>> * and to account the memory you are using, all objects in the page
>> =A0 must belong to you.
>
> Cpusets work at the page boundary and they do not have the requirement yo=
u
> are mentioning of all objects in the page having to belong to a certain
> cpusets. Let that go and things become much easier.
>
>> With a predictable enough workload, this is a recipe for working around =
the
>> very protection we need to establish: one can DoS a physical box full of
>> containers, by always allocating in someone else's pages, and pinning ke=
rnel
>> memory down. Never releasing it, so the shrinkers are useless.
>
> Sure you can construct hyperthetical cases like that. But then that is
> true already of other container like logic in the kernel already.
>
>> So I still believe that if a page is allocated to a cgroup, all the obje=
cts in
>> there belong to it =A0- unless of course the sharing actually means some=
thing -
>> and identifying this is just too complicated.
>
> We have never worked container like logic like that in the kernel due to
> the complicated logic you would have to put in. The requirement that all
> objects in a page come from the same container is not necessary. If you
> drop this notion then things become very easy and the patches will become
> simple.

Back when we (Google) started using cpusets for memory isolation (fake
NUMA), we found that there was a significant isolation breakage coming
from slab pages belonging to one cpuset being used by other cpusets,
which caused us problems: It was very easy for one job to cause slab
growth in another container, which would cause it to OOM, despite
being well-behaved.

Because of this, we had to add logic to prevent that from happening
(by making sure we only allocate objects from pages coming from our
allowed nodes).

Now that we're switching to doing containers with memcg, I think this
is a hard requirement, for us. :-(

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
