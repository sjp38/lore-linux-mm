Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 670F96B0012
	for <linux-mm@kvack.org>; Tue,  3 May 2011 16:09:07 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p43K94eW007409
	for <linux-mm@kvack.org>; Tue, 3 May 2011 13:09:05 -0700
Received: from gxk26 (gxk26.prod.google.com [10.202.11.26])
	by hpaq2.eem.corp.google.com with ESMTP id p43K92JH025089
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 3 May 2011 13:09:03 -0700
Received: by gxk26 with SMTP id 26so195711gxk.4
        for <linux-mm@kvack.org>; Tue, 03 May 2011 13:09:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <m2iptref78.fsf@firstfloor.org>
References: <1304444135-14128-1-git-send-email-yinghan@google.com>
	<m2iptref78.fsf@firstfloor.org>
Date: Tue, 3 May 2011 13:09:02 -0700
Message-ID: <BANLkTi=C9qpkfM1fjeCD_Z_-2rYUifiaUg@mail.gmail.com>
Subject: Re: [PATCH] Eliminate task stack trace duplication.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

On Tue, May 3, 2011 at 12:50 PM, Andi Kleen <andi@firstfloor.org> wrote:
> Ying Han <yinghan@google.com> writes:
>
>> The problem with small dmesg ring buffer like 512k is that only limited =
number
>> of task traces will be logged. Sometimes we lose important information o=
nly
>> because of too many duplicated stack traces.
>>
>> This patch tries to reduce the duplication of task stack trace in the du=
mp
>> message by hashing the task stack. The hashtable is a 32k pre-allocated =
buffer
>> during bootup.
>
> Nice idea! =A0This makes it a lot more readable too.
>
> Can we compress the register values too? (e.g. by not printing that many
> 0s and replacing ffff8 with <k> or so)
>
> In fact I don't remember needing the register values for anything.
> Maybe they could be just not printed by default?

I can look into that, but i might not have time working on this patch
soon. If this is something
nice to have, maybe we can consider merge the first part in and then
add on top of it?

>
>> =A0#endif
>> =A0 =A0 =A0 read_lock(&tasklist_lock);
>> +
>> + =A0 =A0 spin_lock(&stack_hash_lock);
>
> The long hold lock scares me a little bit for a unstable system.
> Could you only hold it while hashing/unhashing?

The patch was initially developed on 2.6.26 kernel and I forward
ported to the latest kernel this time. We've been running the 2.6.26
kernel with the patch for quite long time, and haven't noticed the
problem w/ the locking.

>
> Also when you can't get it fall back to something else.

Can you clarify that?

Thank you for reviewing :)

--Ying
>
> -Andi
> --
> ak@linux.intel.com -- Speaking for myself only
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
