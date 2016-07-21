From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
Date: Thu, 21 Jul 2016 16:52:09 +1000
Message-ID: <15834.7418685027$1469083955@news.gmane.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org> <1468619065-3222-3-git-send-email-keescook@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <kernel-hardening-return-4043-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1468619065-3222-3-git-send-email-keescook@chromium.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias
List-Id: linux-mm.kvack.org

Kees Cook <keescook@chromium.org> writes:

> diff --git a/mm/usercopy.c b/mm/usercopy.c
> new file mode 100644
> index 000000000000..e4bf4e7ccdf6
> --- /dev/null
> +++ b/mm/usercopy.c
> @@ -0,0 +1,234 @@
...
> +
> +/*
> + * Checks if a given pointer and length is contained by the current
> + * stack frame (if possible).
> + *
> + *	0: not at all on the stack
> + *	1: fully within a valid stack frame
> + *	2: fully on the stack (when can't do frame-checking)
> + *	-1: error condition (invalid stack position or bad stack frame)
> + */
> +static noinline int check_stack_object(const void *obj, unsigned long len)
> +{
> +	const void * const stack = task_stack_page(current);
> +	const void * const stackend = stack + THREAD_SIZE;

That allows access to the entire stack, including the struct thread_info,
is that what we want - it seems dangerous? Or did I miss a check
somewhere else?

We have end_of_stack() which computes the end of the stack taking
thread_info into account (end being the opposite of your end above).

cheers
