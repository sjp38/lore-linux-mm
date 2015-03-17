Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 71EFE6B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 21:22:09 -0400 (EDT)
Received: by lagg8 with SMTP id g8so54956242lag.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 18:22:08 -0700 (PDT)
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com. [209.85.215.46])
        by mx.google.com with ESMTPS id ka5si9365702lbc.119.2015.03.16.18.22.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 18:22:07 -0700 (PDT)
Received: by lagg8 with SMTP id g8so54955830lag.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 18:22:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAL82V5O6awBrpj8uf2_cEREzZWPfjLfqPtRbHEd5_zTkRLU8Sg@mail.gmail.com>
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
 <20150316211122.GD11441@amd> <CAL82V5O6awBrpj8uf2_cEREzZWPfjLfqPtRbHEd5_zTkRLU8Sg@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 16 Mar 2015 18:21:44 -0700
Message-ID: <CALCETrU8SeOTSexLOi36sX7Smwfv0baraK=A3hq8twoyBN7NBg@mail.gmail.com>
Subject: Re: [RFC, PATCH] pagemap: do not leak physical addresses to
 non-privileged userspace
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Seaborn <mseaborn@chromium.org>
Cc: Pavel Machek <pavel@ucw.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>

On Mon, Mar 16, 2015 at 5:49 PM, Mark Seaborn <mseaborn@chromium.org> wrote:
> On 16 March 2015 at 14:11, Pavel Machek <pavel@ucw.cz> wrote:
>> On Mon 2015-03-09 23:11:12, Kirill A. Shutemov wrote:
>> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> >
>> > As pointed by recent post[1] on exploiting DRAM physical imperfection,
>> > /proc/PID/pagemap exposes sensitive information which can be used to do
>> > attacks.
>> >
>> > This is RFC patch which disallow anybody without CAP_SYS_ADMIN to read
>> > the pagemap.
>> >
>> > Any comments?
>> >
>> > [1] http://googleprojectzero.blogspot.com/2015/03/exploiting-dram-rowhammer-bug-to-gain.html
>>
>> Note that this kind of attack still works without pagemap, it just
>> takes longer. Actually the first demo program is not using pagemap.
>
> That depends on the machine -- it depends on how bad the machine's
> DRAM is, and whether the machine has the 2x refresh rate mitigation
> enabled.
>
> Machines with less-bad DRAM or with a 2x refresh rate might still be
> vulnerable to rowhammer, but only if the attacker has access to huge
> pages or to /proc/PID/pagemap.
>
> /proc/PID/pagemap also gives an attacker the ability to scan for bad
> DRAM locations, save a list of their addresses, and exploit them in
> the future.
>
> Given that, I think it would still be worthwhile to disable /proc/PID/pagemap.

Having slept on this further, I think that unprivileged pagemap access
is awful and we should disable it with no option to re-enable.  If we
absolutely must, we could allow programs to read all zeros or to read
addresses that are severely scrambled (e.g. ECB-encrypted by a key
generated once per open of pagemap).

Pagemap is awful because:

 - Rowhammer.

 - It exposes internals that users have no business knowing.

 - It could easily leak direct-map addresses, and there's a nice paper
detailing a SMAP bypass using that technique.

Can we just try getting rid of it except with global CAP_SYS_ADMIN.

(Hmm.  Rowhammer attacks targeting SMRAM could be interesting.)

>
>
>> Can we do anything about that? Disabling cache flushes from userland
>> should make it no longer exploitable.
>
> Unfortunately there's no way to disable userland code's use of
> CLFLUSH, as far as I know.
>
> Maybe Intel or AMD could disable CLFLUSH via a microcode update, but
> they have not said whether that would be possible.

The Intel people I asked last week weren't confident.  For one thing,
I fully expect that rowhammer can be exploited using only reads and
writes with some clever tricks involving cache associativity.  I don't
think there are any fully-associative caches, although the cache
replacement algorithm could make the attacks interesting.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
