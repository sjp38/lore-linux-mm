Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 258E76B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:04:41 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 184so17217590iow.19
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:04:41 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0127.outbound.protection.outlook.com. [104.47.38.127])
        by mx.google.com with ESMTPS id h17si5493265ioh.221.2018.04.17.07.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 07:04:39 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Tue, 17 Apr 2018 14:04:36 +0000
Message-ID: <20180417140434.GU2341@sasha-vm>
References: <20180416161412.GZ2341@sasha-vm> <20180416170501.GB11034@amd>
 <20180416171607.GJ2341@sasha-vm>
 <alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm>
 <20180416203629.GO2341@sasha-vm>
 <nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm>
 <20180416211845.GP2341@sasha-vm>
 <nycvar.YFH.7.76.1804162326210.28129@cbobk.fhfr.pm>
 <20180417103936.GC8445@kroah.com> <20180417110717.GB17484@dhcp22.suse.cz>
In-Reply-To: <20180417110717.GB17484@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <FDB4D67F80816D4F92AF9F804A992590@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg KH <greg@kroah.com>, Jiri Kosina <jikos@kernel.org>, Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue, Apr 17, 2018 at 01:07:17PM +0200, Michal Hocko wrote:
>On Tue 17-04-18 12:39:36, Greg KH wrote:
>> On Mon, Apr 16, 2018 at 11:28:44PM +0200, Jiri Kosina wrote:
>> > On Mon, 16 Apr 2018, Sasha Levin wrote:
>> >
>> > > I agree that as an enterprise distro taking everything from -stable
>> > > isn't the best idea. Ideally you'd want to be close to the first
>> > > extreme you've mentioned and only take commits if customers are aski=
ng
>> > > you to do so.
>> > >
>> > > I think that the rule we're trying to agree upon is the "It must fix
>> > > a real bug that bothers people".
>> > >
>> > > I think that we can agree that it's impossible to expect every singl=
e
>> > > Linux user to go on LKML and complain about a bug he encountered, so=
 the
>> > > rule quickly becomes "It must fix a real bug that can bother people"=
.
>> >
>> > So is there a reason why stable couldn't become some hybrid-form union=
 of
>> >
>> > - really critical issues (data corruption, boot issues, severe securit=
y
>> >   issues) taken from bleeding edge upstream
>> > - [reviewed] cherry-picks of functional fixes from major distro kernel=
s
>> >   (based on that very -stable release), as that's apparently what peop=
le
>> >   are hitting in the real world with that particular kernel
>>
>> It already is that :)
>>
>> The problem Sasha is trying to solve here is that for many subsystems,
>> maintainers do not mark patches for stable at all.
>
>The way he is trying to do that is just wrong. Generate a pressure on
>those subsystems by referring to bug reports and unhappy users and I am
>pretty sure they will try harder... You cannot solve the problem by
>bypassing them without having deep understanding of the specific
>subsytem. Once you have it, just make sure you are part of the review
>process and make sure to mark patches before they are merged.

I think we just don't agree on how we should "pressure".

Look at the discussion I had with the XFS folks who just don't want to
deal with this -stable thing because they have to much work upstream.

There wasn't a single patch in -stable coming from XFS for the past 6+
months. I'm aware of more than one way to corrupt an XFS volume for any
distro that uses a kernel older than 4.15.

Sure, please buy them a beer at LSF/MM (I'll pay) and ask them to be
better about it, but I don't see this changing.

The solution to this, in my opinion, is to automate the whole selection
and review process. We do selection using AI, and we run every possible
test that's relevant to that subsystem.

At which point, the amount of work a human needs to do to review a patch
shrinks into something far more managable for some maintainers.

>> So real bugfixes
>> that do hit people are not getting to those kernels, which force the
>> distros to do extra work to triage a bug, dig through upstream kernels,
>> find and apply the patch.
>
>I would say that this is the primary role of the distro. To hide the
>jungle of the upstream work and provide the additional of bug filtering
>and forwarding them the right direction.

More often than triaging, you'll just be asked to upgrade to the latest
version. What sort of user experience does that provide?

[snip]

>> So nothing "new" is happening here, EXCEPT we are actually starting to
>> get a better kernel-wide coverage for stable fixes, which we have not
>> had in the past.  That's a good thing!  The number of patches applied to
>> stable is still a very very very tiny % compared to mainline, so nothing
>> new is happening here.
>
>yes I do agree, the stable process is not very much different from the
>past and I would tend both processes broken because they explicitly try
>to avoid maintainers which is just wrong.

Avoid maintainers?! We send so much "spam" trying to get maintainers
more involved in the process. How is that avoiding them?

If you're a maintainer who has specific requirements for the -stable
flow, or you have any automated testing you'd like to be run on these
commits, or you want these mails to come in a different format, or
pretty much anything else at all just shoot me a mail!

It's been almost impossible to get maintainers involved in this process.

We don't sneak anything past maintainers, there are multiple mails over
multiple weeks for each commit that would go in. You don't have to
review it right away either, just reply with "please don't merge until
I'm done reviewing" and it'll get removed from the queue.

>> Oh, and if you do want to complain about huge new features being
>> backported, look at the mess that Spectre and Meltdown has caused in the
>> stable trees.  I don't see anyone complaining about those massive
>> changes :)
>
>Are you serious? Are you going the compare the biggest PITA that the
>community had to undergo because of HW issues with random pattern
>matching in changelog/diffs? Come on!

HW Issues are irrelevant here. You had a bug that allowed arbitrary
kernel memory access. I can easily list quite a few commits, that are
not tagged for stable, that fix exactly the same thing.=
