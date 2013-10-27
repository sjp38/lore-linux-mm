Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 905FB6B0031
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 12:13:31 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id jt11so5425619pbb.15
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 09:13:31 -0700 (PDT)
Received: from psmtp.com ([74.125.245.124])
        by mx.google.com with SMTP id gj2si10680509pac.167.2013.10.27.09.13.28
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 09:13:29 -0700 (PDT)
Received: by mail-pb0-f73.google.com with SMTP id rr13so350340pbb.0
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 09:13:27 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 2/3] percpu counter: cast this_cpu_sub() adjustment
References: <1382859876-28196-1-git-send-email-gthelen@google.com>
	<1382859876-28196-3-git-send-email-gthelen@google.com>
	<20131027112255.GB14934@mtj.dyndns.org>
	<20131027050429.7fcc2ed5.akpm@linux-foundation.org>
	<20131027130036.GN14934@mtj.dyndns.org>
Date: Sun, 27 Oct 2013 09:13:25 -0700
In-Reply-To: <20131027130036.GN14934@mtj.dyndns.org> (Tejun Heo's message of
	"Sun, 27 Oct 2013 09:00:36 -0400")
Message-ID: <xr93ob6a1yl6.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Sun, Oct 27 2013, Tejun Heo wrote:

> On Sun, Oct 27, 2013 at 05:04:29AM -0700, Andrew Morton wrote:
>> On Sun, 27 Oct 2013 07:22:55 -0400 Tejun Heo <tj@kernel.org> wrote:
>> 
>> > We probably want to cc stable for this and the next one.  How should
>> > these be routed?  I can take these through percpu tree or mm works
>> > too.  Either way, it'd be best to route them together.
>> 
>> Yes, all three look like -stable material to me.  I'll grab them later
>> in the week if you haven't ;)
>
> Tried to apply to percpu but the third one is a fix for a patch which
> was added to -mm during v3.12-rc1, so these are yours. :)

I don't object to stable for the first two non-memcg patches, but it's
probably unnecessary.  I should have made it more clear, but an audit of
v3.12-rc6 shows that only new memcg code is affected - the new
mem_cgroup_move_account_page_stat() is the only place where an unsigned
adjustment is used.  All other callers (e.g. shrink_dcache_sb) already
use a signed adjustment, so no problems before v3.12.  Though I did not
audit the stable kernel trees, so there could be something hiding in
there.

>> The names of the first two patches distress me.  They rather clearly
>> assert that the code affects percpu_counter.[ch], but that is not the case. 
>> Massaging is needed to fix that up.
>
> Yeah, something like the following would be better
>
>  percpu: add test module for various percpu operations
>  percpu: fix this_cpu_sub() subtrahend casting for unsigneds
>  memcg: use __this_cpu_sub() to dec stats to avoid incorrect subtrahend casting

No objection to renaming.  Let me know if you want these reposed with
updated titles.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
