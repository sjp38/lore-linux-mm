Message-ID: <48153297.20502@redhat.com>
Date: Sun, 27 Apr 2008 22:12:39 -0400
From: Masami Hiramatsu <mhiramat@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 36/37] LTTng instrumentation mm
References: <20080424150324.802695381@polymtl.ca> <20080424151408.577430665@polymtl.ca>
In-Reply-To: <20080424151408.577430665@polymtl.ca>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Mathieu,

Mathieu Desnoyers wrote:
> @@ -1844,3 +1848,22 @@ int valid_swaphandles(swp_entry_t entry,
>  	*offset = ++toff;
>  	return nr_pages? ++nr_pages: 0;
>  }
> +
> +void ltt_dump_swap_files(void *call_data)
> +{
> +	int type;
> +	struct swap_info_struct *p = NULL;
> +
> +	mutex_lock(&swapon_mutex);
> +	for (type = swap_list.head; type >= 0; type = swap_info[type].next) {
> +		p = swap_info + type;
> +		if ((p->flags & SWP_ACTIVE) != SWP_ACTIVE)
> +			continue;
> +		__trace_mark(0, statedump_swap_files, call_data,
> +			"filp %p vfsmount %p dname %s",
> +			p->swap_file, p->swap_file->f_vfsmnt,
> +			p->swap_file->f_dentry->d_name.name);
> +	}
> +	mutex_unlock(&swapon_mutex);
> +}
> +EXPORT_SYMBOL_GPL(ltt_dump_swap_files);


I'm not sure this kind of functions can be acceptable.
IMHO, you'd better use more generic method (ex. a callback function),
or just export swap_list and swapon_mutex. Thus, other subsystems can
use that interface.

Thank you,

-- 
Masami Hiramatsu

Software Engineer
Hitachi Computer Products (America) Inc.
Software Solutions Division

e-mail: mhiramat@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
