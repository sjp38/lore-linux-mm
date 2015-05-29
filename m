From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v10 10/12] x86, mm, pat: Cleanup init flags in pat_init()
Date: Fri, 29 May 2015 10:59:20 +0200
Message-ID: <20150529085920.GB31435@pd.tnic>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
 <1432739944-22633-11-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432739944-22633-11-git-send-email-toshi.kani@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de
List-Id: linux-mm.kvack.org

On Wed, May 27, 2015 at 09:19:02AM -0600, Toshi Kani wrote:
> pat_init() uses two flags, 'boot_cpu' and 'boot_pat_state', for
> tracking the boot CPU's initialization status.  'boot_pat_state'
> is also overloaded to carry the boot PAT value.
> 
> This patch cleans this up by replacing them with a new single
> flag, 'boot_cpu_done', to track the boot CPU's initialization
> status.  'boot_pat_state' is only used to carry the boot PAT
> value as a result.
> 
> Suggested-by: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  arch/x86/mm/pat.c |   42 ++++++++++++++++++++----------------------
>  1 file changed, 20 insertions(+), 22 deletions(-)

...

> +		rdmsrl(MSR_IA32_CR_PAT, boot_pat_state);
> +		if (!boot_pat_state) {
> +			pat_disable("PAT read returns always zero, disabled.");
> +			return;
> +		}
> +	} else if (!cpu_has_pat) {
> +		/*
> +		 * If this happens we are on a secondary CPU, but
> +		 * switched to PAT on the boot CPU. We have no way to
> +		 * undo PAT.
> +		 */
> +		pr_err("PAT enabled, but not supported by secondary CPU\n");
> +		BUG();

These could be replaced with a panic().

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
