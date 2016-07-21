From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
Date: Thu, 21 Jul 2016 16:52:09 +1000
Message-ID: <17126.470388803$1469084005@news.gmane.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
 <1468619065-3222-3-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1468619065-3222-3-git-send-email-keescook@chromium.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
To: linux-kernel@vger.kernel.org
Cc: Jan Kara <jack@suse.cz>, kernel-hardening@lists.openwall.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Balbir Singh <bsingharora@gmail.com>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, x86@kernel.org, Russell King <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, Kees Cook <keescook@chromium.org>, Vitaly Wool <vitalywool@gmail.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>
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
