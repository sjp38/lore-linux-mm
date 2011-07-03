Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 27BED6B0012
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 14:28:44 -0400 (EDT)
Received: from mail-ww0-f45.google.com (mail-ww0-f45.google.com [74.125.82.45])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p63IS8Hx002930
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sun, 3 Jul 2011 11:28:10 -0700
Received: by wwj40 with SMTP id 40so3899626wwj.26
        for <linux-mm@kvack.org>; Sun, 03 Jul 2011 11:28:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110703111028.GA2862@albatros>
References: <20110703111028.GA2862@albatros>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 3 Jul 2011 11:27:47 -0700
Message-ID: <CA+55aFzXEoTyK0Sm-y=6xGmLMWzQiSQ7ELJ2-WL_PrP3r44MSg@mail.gmail.com>
Subject: Re: [RFC v1] implement SL*B and stack usercopy runtime checks
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

That patch is entirely insane. No way in hell will that ever get merged.

copy_to/from_user() is some of the most performance-critical code, and
runs a *lot*, often for fairly small structures (ie 'fstat()' etc).

Adding random ad-hoc tests to it is entirely inappropriate. Doing so
unconditionally is insane.

So NAK, NAK, NAK.

If you seriously clean it up (that at a minimum includes things like
making it configurable using some pretty helper function that just
compiles away for all the normal cases, and not writing out

   if (!slab_access_ok(to, n) || !stack_access_ok(to, n))

multiple times, for chrissake) it _might_ be acceptable.

But in its current form it's just total crap. It's exactly the kind of
"crazy security people who don't care about anything BUT security"
crap that I refuse to see.

Some balance and sanity.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
