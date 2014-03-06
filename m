Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 943AA6B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 21:52:26 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id r10so1902808pdi.2
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 18:52:26 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id ki1si3903975pbc.115.2014.03.05.18.52.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Mar 2014 18:52:25 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id z10so1903642pdj.4
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 18:52:25 -0800 (PST)
Date: Wed, 5 Mar 2014 18:52:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 00/11] userspace out of memory handling
In-Reply-To: <20140305131743.b9a916fbc4e40fd895bc4e76@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1403051831100.30075@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com> <20140305131743.b9a916fbc4e40fd895bc4e76@linux-foundation.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-1909896120-1394074344=:30075"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-1909896120-1394074344=:30075
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Wed, 5 Mar 2014, Andrew Morton wrote:

> > This patchset introduces a standard interface through memcg that allows
> > both of these conditions to be handled in the same clean way: users
> > define memory.oom_reserve_in_bytes to define the reserve and this
> > amount is allowed to be overcharged to the process handling the oom
> > condition's memcg.  If used with the root memcg, this amount is allowed
> > to be allocated below the per-zone watermarks for root processes that
> > are handling such conditions (only root may write to
> > cgroup.event_control for the root memcg).
> 
> If process A is trying to allocate memory, cannot do so and the
> userspace oom-killer is invoked, there must be means via which process
> A waits for the userspace oom-killer's action.

It does so by relooping in the page allocator waiting for memory to be 
freed just like it would if the kernel oom killer were called and process 
A was waiting for the oom kill victim process B to exit, we don't have the 
ability to put it on a waitqueue because we don't touch the freeing 
hotpath.  The userspace oom handler may not even necessarily kill 
anything, it may be able to free its own memory and start throttling other 
processes, for example.

> And there must be
> fallbacks which occur if the userspace oom killer fails to clear the
> oom condition, or times out.
> 

I agree completely and proposed this before as memory.oom_delay_millisecs 
at http://lwn.net/Articles/432226 which we use internally when memory 
can't be freed or a memcg's limit cannot be expanded.  I guess it makes 
more sense alongside the rest of this patchset now, I can add it as an 
additional patch next time around.

> Would be interested to see a description of how all this works.
> 

There's an article for LWN also being developed on this topic.  As 
mentioned in that article, I think it would be best to generalize a lot of 
the common functions and the eventfd handling entirely into a library.  
I've attached an example implementation that just invokes a function to 
handle the situation.

For Google's usecase specifically, at the root memcg level (system oom) we 
want to do priority based memcg killing.  We want to kill from within a 
memcg hierarchy that has the lowest priority relative to other memcgs.  
This cannot be implemented with /proc/pid/oom_score_adj today.  Those 
priorities may also change depending on whether a memcg hierarchy is 
"overlimit", i.e. its limit has been increased temporarily because it has 
hit a memcg oom and additional memory is readily available on the system.

So why not just introduce a memcg tunable that specifies a priority?  
Well, it's not that simple.  Other users will want to implement different 
policies on system oom (think about things like existing panic_on_oom or 
oom_kill_allocating_task sysctls).  I introduced oom_kill_allocating_task 
originally for SGI because they wanted a fast oom kill rather than 
expensive tasklist scan: the allocating task itself is rather irrelevant, 
it was just the unlucky task that was allocating at the moment that oom 
was triggered.  What's guaranteed is that current in that case will always 
free memory from under oom (it's not a member of some other mempolicy or 
cpuset that would be needlessly killed).  Both sysctls could trivially be 
reimplemented in userspace with this feature.

I have other customers who don't run in a memcg environment at all, they 
simply reattach all processes to root and delete all other memcgs.  These 
customers are only concerned about system oom conditions and want to do 
something "interesting" before a process is killed.  Some want to log the 
VM statistics as an artifact to examine later, some want to examine heap 
profiles, others can start throttling and freeing memory rather than kill 
anything.  All of this is impossible today because the kernel oom killer 
will simply kill something immediately and any stats we collect afterwards 
don't represent the oom condition.  The heap profiles are lost, throttling 
is useless, etc.

Jianguo (cc'd) may also have usecases not described here.

> It is unfortunate that this feature is memcg-only.  Surely it could
> also be used by non-memcg setups.  Would like to see at least a
> detailed description of how this will all be presented and implemented.
> We should aim to make the memcg and non-memcg userspace interfaces and
> user-visible behaviour as similar as possible.
> 

It's memcg only because it can handle both system and memcg oom conditions 
with the same clean interface, it would be possible to implement only 
system oom condition handling through procfs (a little sloppy since it 
needs to register the eventfd) but then a userspace oom handler would need 
to determine which interface to use based on whether it was running in a 
memcg or non-memcg environment.  I implemented this feature with userspace 
in mind: I didn't want it to need two different implementations to do the 
same thing depending on memcg.  The way it is written, a userspace oom 
handler does not know (nor need not care) whether it is constrained by the 
amount of system RAM or a memcg limit.  It can simply write the reserve to 
its memcg's memory.oom_reserve_in_bytes, attach to memory.oom_control and 
be done.

This does mean that memcg needs to be enabled for the support, though.  
This is already done on most distributions, the cgroup just needs to be 
mounted.  Would it be better to duplicate the interface in two different 
spots depending on CONFIG_MEMCG?  I didn't think so, and I think the idea 
of a userspace library that takes care of this registration (and mounting, 
perhaps) proposed on LWN would be the best of both worlds.

> Patches 1, 2, 3 and 5 appear to be independent and useful so I think
> I'll cherrypick those, OK?
> 

Ok!  I'm hoping that the PF_MEMPOLICY bit that is removed in those patches 
is at least temporarily reserved for PF_OOM_HANDLER introduced here, I 
removed it purposefully :)
--531381512-1909896120-1394074344=:30075
Content-Type: TEXT/x-csrc; name=liboom.c
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.DEB.2.02.1403051852220.30075@chino.kir.corp.google.com>
Content-Description: 
Content-Disposition: attachment; filename=liboom.c

LyoNCiAqDQogKi8NCiNpbmNsdWRlIDxlcnJuby5oPg0KI2luY2x1ZGUgPGZj
bnRsLmg+DQojaW5jbHVkZSA8bGltaXRzLmg+DQojaW5jbHVkZSA8c3RkaW8u
aD4NCiNpbmNsdWRlIDxzdHJpbmcuaD4NCg0KI2luY2x1ZGUgPHN5cy9ldmVu
dGZkLmg+DQojaW5jbHVkZSA8c3lzL21tYW4uaD4NCiNpbmNsdWRlIDxzeXMv
dHlwZXMuaD4NCg0KI2RlZmluZSBTVFJJTkdfTUFYCSg1MTIpDQoNCnZvaWQg
aGFuZGxlX29vbSh2b2lkKQ0Kew0KCXByaW50Zigibm90aWZpY2F0aW9uIHJl
Y2VpdmVkXG4iKTsNCn0NCg0KaW50IHdhaXRfb29tX25vdGlmaWVyKGludCBl
dmVudGZkX2ZkLCB2b2lkICgqaGFuZGxlcikodm9pZCkpDQp7DQoJdWludDY0
X3QgcmV0Ow0KCWludCBlcnI7DQoNCglmb3IgKDs7KSB7DQoJCWVyciA9IHJl
YWQoZXZlbnRmZF9mZCwgJnJldCwgc2l6ZW9mKHJldCkpOw0KCQlpZiAoZXJy
ICE9IHNpemVvZihyZXQpKSB7DQoJCQlmcHJpbnRmKHN0ZGVyciwgInJlYWQo
KVxuIik7DQoJCQlyZXR1cm4gZXJyOw0KCQl9DQoJCWhhbmRsZXIoKTsNCgl9
DQp9DQoNCmludCByZWdpc3Rlcl9vb21fbm90aWZpZXIoY29uc3QgY2hhciAq
bWVtY2cpDQp7DQoJY2hhciBwYXRoW1BBVEhfTUFYXTsNCgljaGFyIGNvbnRy
b2xfc3RyaW5nW1NUUklOR19NQVhdOw0KCWludCBldmVudF9jb250cm9sX2Zk
Ow0KCWludCBjb250cm9sX2ZkOw0KCWludCBldmVudGZkX2ZkOw0KCWludCBl
cnIgPSAwOw0KDQoJZXJyID0gc25wcmludGYocGF0aCwgUEFUSF9NQVgsICIl
cy9tZW1vcnkub29tX2NvbnRyb2wiLCBtZW1jZyk7DQoJaWYgKGVyciA8IDAp
IHsNCgkJZnByaW50ZihzdGRlcnIsICJzbnByaW50ZigpXG4iKTsNCgkJZ290
byBvdXQ7DQoJfQ0KDQoJY29udHJvbF9mZCA9IG9wZW4ocGF0aCwgT19SRE9O
TFkpOw0KCWlmIChjb250cm9sX2ZkID09IC0xKSB7DQoJCWZwcmludGYoc3Rk
ZXJyLCAib3BlbigpOiAlZFxuIiwgZXJybm8pOw0KCQllcnIgPSBlcnJubzsN
CgkJZ290byBvdXQ7DQoJfQ0KDQoJZXZlbnRmZF9mZCA9IGV2ZW50ZmQoMCwg
MCk7DQoJaWYgKGV2ZW50ZmRfZmQgPT0gLTEpIHsNCgkJZnByaW50ZihzdGRl
cnIsICJldmVudGZkKCk6ICVkXG4iLCBlcnJubyk7DQoJCWVyciA9IGVycm5v
Ow0KCQlnb3RvIG91dF9jbG9zZV9jb250cm9sOw0KCX0NCg0KCWVyciA9IHNu
cHJpbnRmKGNvbnRyb2xfc3RyaW5nLCBTVFJJTkdfTUFYLCAiJWQgJWQiLCBl
dmVudGZkX2ZkLA0KCQkgICAgICAgY29udHJvbF9mZCk7DQoJaWYgKGVyciA8
IDApIHsNCgkJZnByaW50ZihzdGRlcnIsICJzbnByaW50ZigpXG4iKTsNCgkJ
Z290byBvdXRfY2xvc2VfZXZlbnRmZDsNCgl9DQoNCgllcnIgPSBzbnByaW50
ZihwYXRoLCBQQVRIX01BWCwgIiVzL2Nncm91cC5ldmVudF9jb250cm9sIiwg
bWVtY2cpOw0KCWlmIChlcnIgPCAwKSB7DQoJCWZwcmludGYoc3RkZXJyLCAi
c25wcmludGYoKVxuIik7DQoJCWdvdG8gb3V0X2Nsb3NlX2V2ZW50ZmQ7DQoJ
fQ0KDQoJZXZlbnRfY29udHJvbF9mZCA9IG9wZW4ocGF0aCwgT19XUk9OTFkp
Ow0KCWlmIChldmVudF9jb250cm9sX2ZkID09IDEpIHsNCgkJZnByaW50Zihz
dGRlcnIsICJvcGVuKCk6ICVkXG4iLCBlcnJubyk7DQoJCWVyciA9IGVycm5v
Ow0KCQlnb3RvIG91dF9jbG9zZV9ldmVudGZkOw0KCX0NCg0KCXdyaXRlKGV2
ZW50X2NvbnRyb2xfZmQsIGNvbnRyb2xfc3RyaW5nLCBzdHJsZW4oY29udHJv
bF9zdHJpbmcpKTsNCgljbG9zZShldmVudF9jb250cm9sX2ZkKTsNCg0KCXJl
dHVybiBldmVudGZkX2ZkOw0KDQpvdXRfY2xvc2VfZXZlbnRmZDoNCgljbG9z
ZShldmVudGZkX2ZkKTsNCm91dF9jbG9zZV9jb250cm9sOg0KCWNsb3NlKGNv
bnRyb2xfZmQpOw0Kb3V0Og0KCXJldHVybiBlcnI7DQp9DQoNCmludCBtYWlu
KGludCBhcmdjLCBjaGFyICoqYXJndikNCnsNCglpbnQgZXZlbnRmZF9mZDsN
CglpbnQgZXJyID0gMDsNCg0KCWlmIChhcmdjICE9IDIpIHsNCgkJZnByaW50
ZihzdGRlcnIsICJ1c2FnZTogJXMgPHBhdGg+XG4iLCBhcmd2WzBdKTsNCgkJ
cmV0dXJuIC0xOw0KCX0NCg0KCWVyciA9IG1sb2NrYWxsKE1DTF9GVVRVUkUp
Ow0KCWlmIChlcnIpIHsNCgkJZnByaW50ZihzdGRlcnIsICIlZFxuIiwgZXJy
bm8pOw0KCQlyZXR1cm4gLTE7DQoJfQ0KDQoJZXZlbnRmZF9mZCA9IHJlZ2lz
dGVyX29vbV9ub3RpZmllcihhcmd2WzFdKTsNCglpZiAoZXZlbnRmZF9mZCA8
IDApIHsNCgkJZnByaW50ZihzdGRlcnIsICIlZFxuIiwgZXJyKTsNCgkJZ290
byBvdXQ7DQoJfQ0KDQoJZXJyID0gd2FpdF9vb21fbm90aWZpZXIoZXZlbnRm
ZF9mZCwgaGFuZGxlX29vbSk7DQoJaWYgKGVycikgew0KCQlmcHJpbnRmKHN0
ZGVyciwgIndhaXRfb29tX25vdGlmaWVyKClcbiIpOw0KCQlnb3RvIG91dDsN
Cgl9DQoNCm91dDoNCgltdW5sb2NrYWxsKCk7DQoJcmV0dXJuIGVycjsNCn0N
Cg==

--531381512-1909896120-1394074344=:30075--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
