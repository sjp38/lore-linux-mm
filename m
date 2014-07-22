From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH 2/3] x86, MCE: Avoid potential deadlock in MCE
Date: Tue, 22 Jul 2014 19:20:44 +0200
Message-ID: <20140722172044.GH6462@pd.tnic>
References: <3908561D78D1C84285E8C5FCA982C28F32871435@ORSMSX114.amr.corp.intel.com>
 <f6ee27db104e769822437234b3fee199d51b5177.1405982894.git.tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f6ee27db104e769822437234b3fee199d51b5177.1405982894.git.tony.luck@intel.com>
Sender: linux-acpi-owner@vger.kernel.org
To: Tony Luck <tony.luck@intel.com>
Cc: "Chen, Gong" <gong.chen@linux.jf.intel.com>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>
List-Id: linux-mm.kvack.org

On Mon, Jul 21, 2014 at 03:44:06PM -0700, Tony Luck wrote:
> 
> This is how much cleaner things could be with a couple of task_struct
> fields instead of the mce_info silliness ... untested.

...

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 0376b054a0d0..91db69a4acd7 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1655,6 +1655,10 @@ struct task_struct {
>  	unsigned int	sequential_io;
>  	unsigned int	sequential_io_avg;
>  #endif
> +#ifdef CONFIG_MEMORY_FAILURE
> +	__u64	paddr;
> +	int	restartable;
> +#endif

Right, I don't see anything wrong with this approach especially as
task_struct is full of CONFIG_* ifdeffery for members used with
different features.

Adding 12 more bytes for CONFIG_MEMORY_FAILURE shouldn't hurt anyone. If
we really want to save space, we can use the highest significant byte of
paddr for a bit to say "restartable" or not.

So I think we should make it into a patch and push it upstream.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
