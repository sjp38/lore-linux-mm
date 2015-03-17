Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 90DD66B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 20:49:51 -0400 (EDT)
Received: by qgfa8 with SMTP id a8so56348242qgf.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 17:49:51 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id 84si11578838qhx.130.2015.03.16.17.49.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 17:49:50 -0700 (PDT)
Received: by qgez64 with SMTP id z64so56411385qge.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 17:49:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150316211122.GD11441@amd>
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name> <20150316211122.GD11441@amd>
From: Mark Seaborn <mseaborn@chromium.org>
Date: Mon, 16 Mar 2015 17:49:30 -0700
Message-ID: <CAL82V5O6awBrpj8uf2_cEREzZWPfjLfqPtRbHEd5_zTkRLU8Sg@mail.gmail.com>
Subject: Re: [RFC, PATCH] pagemap: do not leak physical addresses to
 non-privileged userspace
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andy Lutomirski <luto@amacapital.net>

On 16 March 2015 at 14:11, Pavel Machek <pavel@ucw.cz> wrote:
> On Mon 2015-03-09 23:11:12, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >
> > As pointed by recent post[1] on exploiting DRAM physical imperfection,
> > /proc/PID/pagemap exposes sensitive information which can be used to do
> > attacks.
> >
> > This is RFC patch which disallow anybody without CAP_SYS_ADMIN to read
> > the pagemap.
> >
> > Any comments?
> >
> > [1] http://googleprojectzero.blogspot.com/2015/03/exploiting-dram-rowhammer-bug-to-gain.html
>
> Note that this kind of attack still works without pagemap, it just
> takes longer. Actually the first demo program is not using pagemap.

That depends on the machine -- it depends on how bad the machine's
DRAM is, and whether the machine has the 2x refresh rate mitigation
enabled.

Machines with less-bad DRAM or with a 2x refresh rate might still be
vulnerable to rowhammer, but only if the attacker has access to huge
pages or to /proc/PID/pagemap.

/proc/PID/pagemap also gives an attacker the ability to scan for bad
DRAM locations, save a list of their addresses, and exploit them in
the future.

Given that, I think it would still be worthwhile to disable /proc/PID/pagemap.


> Can we do anything about that? Disabling cache flushes from userland
> should make it no longer exploitable.

Unfortunately there's no way to disable userland code's use of
CLFLUSH, as far as I know.

Maybe Intel or AMD could disable CLFLUSH via a microcode update, but
they have not said whether that would be possible.

Cheers,
Mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
