Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 186856B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 18:40:00 -0400 (EDT)
Message-ID: <50492574.6030308@parallels.com>
Date: Fri, 7 Sep 2012 02:36:36 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/5] forced comounts for cgroups.
References: <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com> <5047074D.1030104@parallels.com> <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com> <50470A87.1040701@parallels.com> <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com> <50470EBF.9070109@parallels.com> <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com> <1346835993.2600.9.camel@twins> <20120905093204.GL3195@dhcp-172-17-108-109.mtv.corp.google.com> <1346839487.2600.24.camel@twins> <20120906204642.GN29092@google.com> <CAPM31RKVYpkc0oTJKjsdsvqBfif=Bovi3a6TE8qdOOpEYOC0Lw@mail.gmail.com>
In-Reply-To: <CAPM31RKVYpkc0oTJKjsdsvqBfif=Bovi3a6TE8qdOOpEYOC0Lw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Turner <pjt@google.com>
Cc: Tejun Heo <tj@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, lennart@poettering.net, kay.sievers@vrfy.org, Dhaval Giani <dhaval.giani@gmail.com>, Frederic Weisbecker <fweisbec@gmail.com>

On 09/07/2012 01:11 AM, Paul Turner wrote:
> On Thu, Sep 6, 2012 at 1:46 PM, Tejun Heo <tj@kernel.org> wrote:
>> Hello,
>>
>> cc'ing Dhaval and Frederic.  They were interested in the subject
>> before and Dhaval was pretty vocal about cpuacct having a separate
>> hierarchy (or at least granularity).
> 
> Really?  Time just has _not_ borne out this use-case.  I'll let Dhaval
> make a case for this but he should expect violent objection.
> 

I strongly advise against physical violence. In case it is really
necessary, please break his legs only.

>> On Wed, Sep 05, 2012 at 12:04:47PM +0200, Peter Zijlstra wrote:
>>>> cpuacct is rather unique tho.  I think it's gonna be silly whether the
>>>> hierarchy is unified or not.
>>>>
>>>> 1. If they always can live on the exact same hierarchy, there's no
>>>>    point in having the two separate.  Just merge them.
>>>>
>>>> 2. If they need differing levels of granularity, they either need to
>>>>    do it completely separately as they do now or have some form of
>>>>    dynamic optimization if absolutely necesary.
>>>>
>>>> So, I think that choice is rather separate from other issues.  If
>>>> cpuacct is gonna be kept, I'd just keep it separate and warn that it
>>>> incurs extra overhead for the current users if for nothing else.
>>>> Otherwise, kill it or merge it into cpu.
>>>
>>> Quite, hence my 'proposal' to remove cpuacct.
>>>
>>> There was some whining last time Glauber proposed this, but the one
>>> whining never convinced and has gone away from Linux, so lets just do
>>> this.
>>>
>>> Lets make cpuacct print a deprecated msg to dmesg for a few releases and
>>> make cpu do all this.
>>
>> I like it.  Currently cpuacct is the only problematic one in this
>> regard (cpuset to a much lesser extent) and it would be great to make
>> it go away.
>>
>> Dhaval, Frederic, Paul, if you guys object, please voice your
>> opinions.
>>
>>> The co-mounting stuff would have been nice for cpusets as well, knowing
>>> all your tasks are affine to a subset of cpus allows for a few
>>> optimizations (smaller cpumask iterations), but I guess we'll have to do
>>> that dynamically, we'll just have to see how ugly that is.
>>
>> Forced co-mounting sounds rather silly to me.  If the two are always
>> gonna be co-mounted, why not just merge them and switch the
>> functionality depending on configuration?  I'm fairly sure the code
>> would be simpler that way.
> 
> It would be simpler but the problem is we'd break any userspace that
> was just doing mount cpuacct?
> 
> Further, even if it were mounting both, userspace code still has to be
> changed to read from "cpu.export" instead of "cpuacct.export".
> 

Only if we remove cpuacct. What we can do, and I thought about doing, is
just merging cpuacct functionality into cpu. Then we move cpuacct to
default no. It will be there for userspace if they absolutely want to
use it.

> I think a sane path on this front is:
> 
> Immediately:
> Don't allow cpuacct and cpu to be co-mounted on separate hierarchies
> simultaneously.
> 
that is precisely what my patch does, except it is a bit more generic.

> That is:
> mount none /dev/cgroup/cpuacct -t cgroupfs -o cpuacct : still works
> mount none /dev/cgroup/cpu -t cgroupfs -o cpu : still works
> mount none /dev/cgroup/cpux -t cgroupfs -o cpuacct,cpu : still works
> 
> But the combination:
> mount none /dev/cgroup/cpu -t cgroupfs -o cpu : still works
> mount none /dev/cgroup/cpuacct -t cgroupfs -o cpu : EINVAL [or vice versa].
> 
> Also:
> WARN_ON when mounting cpuacct without cpu, strongly explaining that
> ANY such configuration is deprecated.
> 
> Glauber's patchset goes most of the way towards enabling this.
>
yes.

> In a release or two:
> Make the restriction strict; don't allow individual mounting of
> cpuacct, force it to be mounted ONLY with cpu.
> 
> Glauber's patchset gives us this.
> 
> Finally:
> Mirror the interfaces to cpu, print nasty syslog messages about ANY
> mounts of cpuacct
> Follow that up by eventually removing cpuacct completely
>
Why don't start with mirroring? It gives more time for people to start
switching to it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
