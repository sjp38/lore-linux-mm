Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 239726B0012
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 15:11:30 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p63JAoAg005389
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sun, 3 Jul 2011 12:10:51 -0700
Received: by wyg36 with SMTP id 36so4125939wyg.14
        for <linux-mm@kvack.org>; Sun, 03 Jul 2011 12:10:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110703185709.GA7414@albatros>
References: <20110703111028.GA2862@albatros> <CA+55aFzXEoTyK0Sm-y=6xGmLMWzQiSQ7ELJ2-WL_PrP3r44MSg@mail.gmail.com>
 <20110703185709.GA7414@albatros>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 3 Jul 2011 12:10:29 -0700
Message-ID: <CA+55aFwuvk7xifqCX=E3DtV=JCJEzyODcF4o6xLL0U1N_P-Rbg@mail.gmail.com>
Subject: Re: [RFC v1] implement SL*B and stack usercopy runtime checks
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Sun, Jul 3, 2011 at 11:57 AM, Vasiliy Kulikov <segoon@openwall.com> wrote:
>> If you seriously clean it up (that at a minimum includes things like
>> making it configurable using some pretty helper function that just
>> compiles away for all the normal cases,
>
> Hm, it is not as simple as it looks at the first glance - even if the
> object size is known at the compile time (__compiletime_object_size), it
> might be a field of a structure, which crosses the slab object
> boundaries because of an overflow.

No, I was more talking about having something like

  #ifdef CONFIG_EXPENSIVE_CHECK_USERCOPY
  extern int check_user_copy(const void *kptr, unsigned long size);
  #else
  static inline int check_user_copy(const void *kptr, unsigned long size)
  { return 0; }
  #endif

so that the actual user-copy routines end up being clean and not have
#ifdefs in them or any implementation details like what you check
(stack, slab, page cache - whatever)

If you can also make it automatically not generate any code for cases
that are somehow obviously safe, then that's an added bonus.

But my concern is that performance is a real issue, and the strict
user-copy checking sounds like mostly a "let's enable this for testing
kernels when chasing some particular issue" feature, the way
DEBUG_PAGEALLOC is. And at the same time, code cleanliness and
maintainability is a big deal, so the usercopy code itself should have
minimal impact and look nice regardless (which is why I strongly
object to that kind of "(!slab_access_ok(to, n) ||
!stack_access_ok(to, n))" crud - the internal details of what you
check are *totally* irrelevant to the usercopy code.

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
