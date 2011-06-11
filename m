Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 75F9B6B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 20:46:43 -0400 (EDT)
Received: by bwz17 with SMTP id 17so3980730bwz.14
        for <linux-mm@kvack.org>; Fri, 10 Jun 2011 17:46:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1106101425400.28334@sister.anvils>
References: <20110609212956.GA2319@redhat.com>
	<BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com>
	<BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com>
	<20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1106091812030.4904@sister.anvils>
	<20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1106101425400.28334@sister.anvils>
Date: Sat, 11 Jun 2011 09:46:40 +0900
Message-ID: <BANLkTi=bBSeMFtUDyz+px1Kt34HDU=DEcw@mail.gmail.com>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

2011/6/11 Hugh Dickins <hughd@google.com>:
> On Fri, 10 Jun 2011, KAMEZAWA Hiroyuki wrote:
>>
>> I think this can be a fix.
>
> Sorry, I think not: I've not digested your rationale,
> but three things stand out:
>
> 1. Why has this only just started happening? =A0I may not have run that
> =A0 test on 3.0-rc1, but surely I ran it for hours with 2.6.39;
> =A0 maybe not with khugepaged, but certainly with ksmd.
>
Not sure. I pointed this just by review because I found "charge" in
khugepaged is out of mmap_sem now.

> 2. Your hunk below:
>> - =A0 =A0 if (!mm_need_new_owner(mm, p))
>> + =A0 =A0 if (!mm_need_new_owner(mm, p)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(mm->owner, NULL);
> =A0 is now setting mm->owner to NULL at times when we were sure it did no=
t
> =A0 need updating before (task is not the owner): you're damaging mm->own=
er.
>
Ah, yes. It's my mistake.

> 3. There's a patch from Andrea in 3.0-rc1 which looks very likely to be
> =A0 relevant, 692e0b35427a "mm: thp: optimize memcg charge in khugepaged"=
.
> =A0 I'll try reproducing without that tonight (I crashed in 20 minutes
> =A0 this morning, so it's not too hard).
>

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
