Received: by hs-out-0708.google.com with SMTP id l65so1118563hsc.6
        for <linux-mm@kvack.org>; Mon, 10 Nov 2008 14:03:19 -0800 (PST)
Message-ID: <4918AFA1.4000102@gmail.com>
Date: Mon, 10 Nov 2008 23:03:13 +0100
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm: fine-grained dirty_ratio_pcm and dirty_background_ratio_pcm
 (v2)
References: <1221232192-13553-1-git-send-email-righi.andrea@gmail.com>	<20080912131816.e0cfac7a.akpm@linux-foundation.org>	<532480950809221641y3471267esff82a14be8056586@mail.gmail.com>	<48EB4236.1060100@linux.vnet.ibm.com>	<48EB851D.2030300@gmail.com>	<20081008101642.fcfb9186.kamezawa.hiroyu@jp.fujitsu.com>	<48ECB215.4040409@linux.vnet.ibm.com>	<48EE236A.90007@gmail.com>	<4918A074.1050003@gmail.com> <20081110131255.ce71ce60.akpm@linux-foundation.org>
In-Reply-To: <20081110131255.ce71ce60.akpm@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, balbir@linux.vnet.ibm.com, mrubin@google.com, menage@google.com, dave@linux.vnet.ibm.com, chlunde@ping.uio.no, dpshah@google.com, eric.rannaud@gmail.com, fernando@oss.ntt.co.jp, agk@sourceware.org, m.innocenti@cineca.it, s-uchida@ap.jp.nec.com, ryov@valinux.co.jp, matt@bluehost.com, dradford@bluehost.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

On 2008-11-10 22:12, Andrew Morton wrote:
> On Mon, 10 Nov 2008 21:58:28 +0100
> Andrea Righi <righi.andrea@gmail.com> wrote:
> 
>> The current granularity of 5% of dirtyable memory for dirty pages writeback is
>> too coarse for large memory machines and this will get worse as
>> memory-size/disk-speed ratio continues to increase.
>>
>> These large writebacks can be unpleasant for desktop or latency-sensitive
>> environments, where the time to complete each writeback can be perceived as a
>> lack of responsiveness by the whole system.
>>
>> Following there's a similar solution as discussed in [1], but a little
>> bit simplified in order to provide the same functionality (in particular
>> to avoid backward compatibility problems) and reduce the amount of code
>> needed to implement an in-kernel parser to handle percentages with
>> decimals digits.
>>
>> The kernel provides the following parameters:
>>  - dirty_ratio, dirty_background_ratio in percentage (1 ... 100)
>>  - dirty_ratio_pcm, dirty_background_ratio_pcm in units of percent mille (1 ... 100,000)
> 
> hm, so how long until dirty_ratio_pcm becomes too coarse...
> 
> What happened to the idea of specifying these in units of kilobytes?

The conclusion was that with units in KB requires much more complexity
to keep in sync the old dirty_ratio (and dirty_background_ratio)
interface with the new one.

The KB limit is a static value, the other depends on the dirtyable
memory. If we want to preserve the same behaviour we should do the
following:

- when dirty_ratio changes to x:
  dirty_amount_in_bytes = x * dirtyable_memory / 100.

- when dirty_amount_in_bytes changes to x:
  dirty_ratio = x / dirtyable_memory * 100

But anytime the dirtyable memory changes (as well as the total memory in
the system) we should update both values accordingly to preserve the
coherency between them.

I wonder if setting also PERCENT_PCM (that is 1% expressed in
fine-grained units) as a parameter could be a better long-term solution.
And also use another name for it, because in this case this would be not
a milli-percent value anymore.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
