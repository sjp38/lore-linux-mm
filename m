Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9DE006B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 19:38:50 -0500 (EST)
Received: by iwn33 with SMTP id 33so2694225iwn.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 16:38:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101121173726.GG23423@thunk.org>
References: <20101121112611.GB4267@deepthought.bhanu.net>
	<20101121133024.GF23423@thunk.org>
	<20101121153949.GD20947@barrios-desktop>
	<20101121173726.GG23423@thunk.org>
Date: Mon, 22 Nov 2010 09:38:49 +0900
Message-ID: <AANLkTimeSWWo-TAJPPH81OO_h1zFzWAT1Gg=XSLyFftH@mail.gmail.com>
Subject: Re: [BUG?] [Ext4] INFO: suspicious rcu_dereference_check() usage
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ted Ts'o <tytso@mit.edu>, Minchan Kim <minchan.kim@gmail.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andreas Dilger <adilger.kernel@dilger.ca>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Eric Sandeen <sandeen@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 2:37 AM, Ted Ts'o <tytso@mit.edu> wrote:
> On Mon, Nov 22, 2010 at 12:39:49AM +0900, Minchan Kim wrote:
>>
>> I think it's no problem.
>>
>> That's because migration always holds lock_page on the file page.
>> So the page couldn't remove from radix.
>
> It may be "ok" in that it won't cause a race, but it still leaves an
> unsightly warning if LOCKDEP is enabled, and LOCKDEP warnings will
> cause /proc_lock_stat to be disabled. =A0So I think it still needs to be
> fixed by adding rcu_read_lock()/rcu_read_unlock() to
> migrate_page_move_mapping().
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 - Ted
>

Yes. if it is really "ok" about race, we will add rcu_read_lock with
below comment to prevent false positive.
"suppress RCU lockdep false positives".
But I am not sure it's good although rcu_read_lock is little cost.
Whenever we find false positive, should we add rcu_read_lock to
suppress although it's no problem in real product?
Couldn't we provide following function? (or we might have already it
but I missed it. )

/*
 * Suppress RCU lockdep false positive.
 */
#ifdef CONFIG_PROVE_RCU
#define rcu_read_lock_suppress rcu_read_lock
#else
#define rcu_read_lock_suppress
#endif


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
