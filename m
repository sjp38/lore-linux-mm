Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE646B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:41:11 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b11so2481866itj.0
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 18:41:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m125sor7436895itg.66.2018.01.30.18.41.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jan 2018 18:41:10 -0800 (PST)
Date: Tue, 30 Jan 2018 18:41:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] tools, vm: new option to specify kpageflags file fix
 fix
In-Reply-To: <20180130160041.ced8e9bbb4741494147f476f@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1801301840050.140969@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801301458180.153857@chino.kir.corp.google.com> <20180130160041.ced8e9bbb4741494147f476f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 30 Jan 2018, Andrew Morton wrote:

> On Tue, 30 Jan 2018 15:01:01 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
> 
> > page-types currently hardcodes /proc/kpageflags as the file to parse.  
> > This works when using the tool to examine the state of pageflags on the 
> > same system, but does not allow storing a snapshot of pageflags at a given 
> > time to debug issues nor on a different system.
> > 
> > This allows the user to specify a saved version of kpageflags with a new 
> > page-types -F option.
> > 
> 
> This, methinks:
> 
> --- a/tools/vm/page-types.c~tools-vm-new-option-to-specify-kpageflags-file-fix
> +++ a/tools/vm/page-types.c
> @@ -791,7 +791,7 @@ static void usage(void)
>  "            -N|--no-summary            Don't show summary info\n"
>  "            -X|--hwpoison              hwpoison pages\n"
>  "            -x|--unpoison              unpoison pages\n"
> -"            -F|--kpageflags            kpageflags file to parse\n"
> +"            -F|--kpageflags filename   kpageflags file to parse\n"
>  "            -h|--help                  Show this usage message\n"
>  "flags:\n"
>  "            0x10                       bitfield format, e.g.\n"

Please find a "fix fix" below per Naoya.  Thanks both!

diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -169,10 +169,10 @@ static int		opt_raw;	/* for kernel developers */
 static int		opt_list;	/* list pages (in ranges) */
 static int		opt_no_summary;	/* don't show summary */
 static pid_t		opt_pid;	/* process to walk */
-const char *		opt_file;	/* file or directory path */
+const char		*opt_file;	/* file or directory path */
 static uint64_t		opt_cgroup;	/* cgroup inode */
 static int		opt_list_cgroup;/* list page cgroup */
-static const char *	opt_kpageflags;	/* kpageflags file to parse */
+static const char	*opt_kpageflags;/* kpageflags file to parse */
 
 #define MAX_ADDR_RANGES	1024
 static int		nr_addr_ranges;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
