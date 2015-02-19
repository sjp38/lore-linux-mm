Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id EA4FC900015
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 22:23:46 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id vb8so9950580obc.12
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 19:23:46 -0800 (PST)
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com. [209.85.214.182])
        by mx.google.com with ESMTPS id mr4si2907191oeb.7.2015.02.18.19.23.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Feb 2015 19:23:46 -0800 (PST)
Received: by mail-ob0-f182.google.com with SMTP id nt9so9723818obb.13
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 19:23:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1424304641-28965-2-git-send-email-dbueso@suse.de>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	<1424304641-28965-2-git-send-email-dbueso@suse.de>
Date: Wed, 18 Feb 2015 22:23:45 -0500
Message-ID: <CAHC9VhR212FmSEhV_2yryt0=YxTN34ktZ8vveBD3kv4Uhd4WTw@mail.gmail.com>
Subject: Re: [PATCH 1/3] kernel/audit: consolidate handling of mm->exe_file
From: Paul Moore <paul@paul-moore.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dbueso@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net, Eric Paris <eparis@redhat.com>, linux-audit@redhat.com

On Wed, Feb 18, 2015 at 7:10 PM, Davidlohr Bueso <dbueso@suse.de> wrote:
> From: Davidlohr Bueso <dave@stgolabs.net>
>
> This patch adds a audit_log_d_path_exe() helper function
> to share how we handle auditing of the exe_file's path.
> Used by both audit and auditsc. No functionality is changed.
>
> Cc: Paul Moore <paul@paul-moore.com>
> Cc: Eric Paris <eparis@redhat.com>
> Cc: linux-audit@redhat.com
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> ---
>
> Compile tested only.
>
>  kernel/audit.c   |  9 +--------
>  kernel/audit.h   | 14 ++++++++++++++
>  kernel/auditsc.c |  9 +--------
>  3 files changed, 16 insertions(+), 16 deletions(-)

I'd prefer if the audit_log_d_path_exe() helper wasn't a static inline.

> --- a/kernel/audit.h
> +++ b/kernel/audit.h
> @@ -257,6 +257,20 @@ extern struct list_head audit_filter_list[];
>
>  extern struct audit_entry *audit_dupe_rule(struct audit_krule *old);
>
> +static inline void audit_log_d_path_exe(struct audit_buffer *ab,
> +                                       struct mm_struct *mm)
> +{
> +       if (!mm) {
> +               audit_log_format(ab, " exe=(null)");
> +               return;
> +       }
> +
> +       down_read(&mm->mmap_sem);
> +       if (mm->exe_file)
> +               audit_log_d_path(ab, " exe=", &mm->exe_file->f_path);
> +       up_read(&mm->mmap_sem);
> +}
> +
>  /* audit watch functions */
>  #ifdef CONFIG_AUDIT_WATCH
>  extern void audit_put_watch(struct audit_watch *watch);

-- 
paul moore
www.paul-moore.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
