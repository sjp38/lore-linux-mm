Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id m5B84JsT004906
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 09:04:19 +0100
Received: from an-out-0708.google.com (anab2.prod.google.com [10.100.53.2])
	by spaceape9.eur.corp.google.com with ESMTP id m5B84IKT025341
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 09:04:18 +0100
Received: by an-out-0708.google.com with SMTP id b2so629087ana.25
        for <linux-mm@kvack.org>; Wed, 11 Jun 2008 01:04:18 -0700 (PDT)
Message-ID: <6599ad830806110104n99cdc7h80063e91d16bf0a5@mail.gmail.com>
Date: Wed, 11 Jun 2008 01:04:14 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
In-Reply-To: <20080611164544.94047336.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com>
	 <20080611164544.94047336.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 11, 2008 at 12:45 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> Is it really such a big deal if we don't transfer the page ownerships
>> to the new cgroup? As this thread has shown, it's a fairly painful
>> operation to support. It would be good to have some concrete examples
>> of cases where this is needed.
>>
> When we moves a process with XXXG bytes of memory, we need "move" obviously.

That's not a concrete example, it's an assertion :-)

>
> I think there is a case that system administrator decides to create _new_
> cgroup to isolate some swappy job for maintaining the system.
> (I never be able to say that never happens.)

OK, that seems like a reasonable case - i.e. when an existing cgroup
is deliberately split into two.

An alternative way to support that would be to do nothing at move
time, but provide a "pull_usage" control file that would slurp any
pages in any mm in the cgroup into the cgroup.
>> >
>> > One reasone is that I think a typical usage of memory controller is
>> > fork()->move->exec(). (by libcg ?) and exec() will flush the all usage.
>>
>> Exactly - this is a good reason *not* to implement move - because then
>> you drag all the usage of the middleware daemon into the new cgroup.
>>
> Yes but this is one of the usage of cgroup. In general, system admin can
> use this for limiting memory on his own decision.
>

Sorry, your last sentence doesn't make sense to me in this context.

If the common mode for middleware starting a new cgroup is fork() /
move / exec() then after the fork(), the child will be sharing pages
with the main daemon process. So the move will pull all the daemon's
memory into the new cgroup

> yes. but, at first, I'll try no-rollback approach.
> And can I move memory resource controller's subsys_id to the last for now ?
>

That's probably fine for experimentation, but it wouldn't be something
we'd want to commit to -mm or mainline.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
