Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 687C16B0068
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 04:38:37 -0400 (EDT)
Message-ID: <50470EBF.9070109@parallels.com>
Date: Wed, 5 Sep 2012 12:35:11 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/5] forced comounts for cgroups.
References: <1346768300-10282-1-git-send-email-glommer@parallels.com> <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com> <5047074D.1030104@parallels.com> <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com> <50470A87.1040701@parallels.com> <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com>
In-Reply-To: <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

On 09/05/2012 12:29 PM, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Wed, Sep 05, 2012 at 12:17:11PM +0400, Glauber Costa wrote:
>>> Distros can just co-mount them during boot.  What's the point of the
>>> config options?
>>
>> Pretty simple. The kernel can't assume the distro did. And then we still
>> need to pay a stupid big price in the scheduler.
>>
>> After this patchset, We can assume this. And cpuusage can totally be
>> derived from the cpu cgroup. Because much more than "they can comount",
>> we can assume they did.
> 
> As long as cpuacct and cpu are separate, I think it makes sense to
> assume that they at least could be at different granularity.  

If they are comounted, and more: forceably comounted, I don't see how to
call them separate. At the very best, they are this way for
compatibility purposes only, to lay a path that would allow us to get
rid of the separation eventually.

> As for
> optimization for co-mounted case, if that is *really* necessary,
> couldn't it be done dynamically?  It's not like CONFIG_XXX blocks are
> pretty things and they're worse for runtime code path coverage.
> 

I've done it dynamically, as you know. But if you think that complicated
the code less than this, we're operating by very different standards...

CONFIG options can make the code uglier, but it is a lot more
predictable. It also guarantee no state changes will happen during the
lifecycle of the machine. Doing it dynamically makes the code prettier,
but still extensively large, and prone to subtle bugs, as we've already
seen in practice.

>>> Differing hierarchies in memcg and blkcg currently is the most
>>> prominent case where the intersection in writeback is problematic and
>>> your proposed solution doesn't help one way or the other.  What's the
>>> point?
>>
>> The point is that I am focusing at one problem at a time. But FWIW, I
>> don't see why memcg/blkcg can't use a step just like this one in a
>> separate pass.
>>
>> If the goal is comounting them eventually, at some point when the issues
>> are sorted out, just do it. Get a switch like this one, and then you
>> will start being able to assume a lot of things in the code. Miracles
>> can happen.
> 
> The problem is that I really don't see how this leads to where we
> eventually wanna be.  Orthogonal hierarchies are bad because,
> 
> * It complicates the code.  This doesn't really help there much.
> 

Way I see it, it is the price we pay for having screwed up before.
And Kconfig options doesn't necessarily complicate the code. They make
it bigger, and possibly slightly harder to follow. But I myself

> * Intersections between controllers are cumbersome to handle.  Again,
>   this doesn't help much.
>

They are only cumbersome because we can't assume nothing. The cpuacct is
the perfect example. Once we can start assuming, they become a lot less so.


> And this restricts the only valid use case for multiple hierarchies
> which is applying differing level of granularity depending on
> controllers.  So, I don't know.  Doesn't seem like a good idea to me.
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
