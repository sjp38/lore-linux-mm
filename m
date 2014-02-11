From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH v5 1/3] mm: Create utility function for accessing a tasks
	commandline value
Date: Tue, 11 Feb 2014 11:29:44 -0500
Message-ID: <20140211162944.GK18807@madcap2.tricolour.ca>
References: <1391710528-23481-1-git-send-email-wroberts@tresys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-audit-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <1391710528-23481-1-git-send-email-wroberts@tresys.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
To: William Roberts <bill.c.roberts@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, William Roberts <wroberts@tresys.com>, linux-audit@redhat.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org
List-Id: linux-mm.kvack.org

On 14/02/06, William Roberts wrote:
> introduce get_cmdline() for retreiving the value of a processes
> proc/self/cmdline value.
> 
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Stephen Smalley <sds@tycho.nsa.gov>

Acked-by: Richard Guy Briggs <rgb@redhat.com>

> Signed-off-by: William Roberts <wroberts@tresys.com>
> ---
>  include/linux/mm.h |    1 +
>  mm/util.c          |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 49 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f28f46e..db89a94 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1175,6 +1175,7 @@ void account_page_writeback(struct page *page);
>  int set_page_dirty(struct page *page);
>  int set_page_dirty_lock(struct page *page);
>  int clear_page_dirty_for_io(struct page *page);
> +int get_cmdline(struct task_struct *task, char *buffer, int buflen);
>  
>  /* Is the vma a continuation of the stack vma above it? */
>  static inline int vma_growsdown(struct vm_area_struct *vma, unsigned long addr)
> diff --git a/mm/util.c b/mm/util.c
> index a24aa22..8122710 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -445,6 +445,54 @@ unsigned long vm_commit_limit(void)
>  	return allowed;
>  }
>  
> +/**
> + * get_cmdline() - copy the cmdline value to a buffer.
> + * @task:     the task whose cmdline value to copy.
> + * @buffer:   the buffer to copy to.
> + * @buflen:   the length of the buffer. Larger cmdline values are truncated
> + *            to this length.
> + * Returns the size of the cmdline field copied. Note that the copy does
> + * not guarantee an ending NULL byte.
> + */
> +int get_cmdline(struct task_struct *task, char *buffer, int buflen)
> +{
> +	int res = 0;
> +	unsigned int len;
> +	struct mm_struct *mm = get_task_mm(task);
> +	if (!mm)
> +		goto out;
> +	if (!mm->arg_end)
> +		goto out_mm;	/* Shh! No looking before we're done */
> +
> +	len = mm->arg_end - mm->arg_start;
> +
> +	if (len > buflen)
> +		len = buflen;
> +
> +	res = access_process_vm(task, mm->arg_start, buffer, len, 0);
> +
> +	/*
> +	 * If the nul at the end of args has been overwritten, then
> +	 * assume application is using setproctitle(3).
> +	 */
> +	if (res > 0 && buffer[res-1] != '\0' && len < buflen) {
> +		len = strnlen(buffer, res);
> +		if (len < res) {
> +			res = len;
> +		} else {
> +			len = mm->env_end - mm->env_start;
> +			if (len > buflen - res)
> +				len = buflen - res;
> +			res += access_process_vm(task, mm->env_start,
> +						 buffer+res, len, 0);
> +			res = strnlen(buffer, res);
> +		}
> +	}
> +out_mm:
> +	mmput(mm);
> +out:
> +	return res;
> +}
>  
>  /* Tracepoints definitions. */
>  EXPORT_TRACEPOINT_SYMBOL(kmalloc);
> -- 
> 1.7.9.5
> 

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
