Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED8376B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 20:16:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n18so2814419pfe.7
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 17:16:04 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id h190si5117157pgc.72.2016.10.26.17.16.03
        for <linux-mm@kvack.org>;
        Wed, 26 Oct 2016 17:16:04 -0700 (PDT)
Date: Thu, 27 Oct 2016 09:17:15 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [v3,6/9] mm/page_owner: use stackdepot to store stacktrace
Message-ID: <20161027001715.GA5655@js1304-P5Q-DELUXE>
References: <1466150259-27727-7-git-send-email-iamjoonsoo.kim@lge.com>
 <toe60ofdzuq.fsf@twin.sascha.silbe.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <toe60ofdzuq.fsf@twin.sascha.silbe.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sascha Silbe <x-linux@infra-silbe.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

Hello,

Thanks for the report.

On Wed, Oct 26, 2016 at 03:06:05PM +0200, Sascha Silbe wrote:
> Dear Joonsoo,
> 
> Joonsoo Kim <js1304@gmail.com> writes:
> 
> > Currently, we store each page's allocation stacktrace on corresponding
> > page_ext structure and it requires a lot of memory.  This causes the
> > problem that memory tight system doesn't work well if page_owner is
> > enabled.  Moreover, even with this large memory consumption, we cannot get
> > full stacktrace because we allocate memory at boot time and just maintain
> > 8 stacktrace slots to balance memory consumption.  We could increase it to
> > more but it would make system unusable or change system behaviour.
> [...]
> 
> This patch causes my Wandboard Quad [1] not to boot anymore. I don't get
> any kernel output, even with earlycon enabled
> (earlycon=ec_imx6q,0x02020000). git bisect pointed towards your patch;
> reverting the patch causes the system to boot fine again. Config is
> available at [2]; none of the defconfigs I tried (defconfig =
> multi_v7_defconfig, imx_v6_v7_defconfig) works for me.
> 
> Haven't looked into this any further so far; hooking up a JTAG adapter
> requires some hardware changes as the JTAG header is unpopulated.
> 
> Sascha
> 
> PS: Please CC me on replies; I'm not subscribed to any of the lists.
> 
> [1] http://www.wandboard.org/index.php/details/wandboard
> [2] https://sascha.silbe.org/tmp/config-4.8.4-wandboard-28-00003-g9e9b5d6
> -- 
> Softwareentwicklung Sascha Silbe, Niederhofenstrasse 5/1, 71229 Leonberg
> https://se-silbe.de/
> USt-IdNr.: DE281696641


I cannot see your config. Link [2] shows "No such file or directory"

Anyway, I find that there is an issue in early boot phase in
!CONFIG_SPARSEMEM. Could you try following one?
(It's an completely untested patch, even I don't try to compile it.)

Thanks.

---------->8---------------
diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index 9298c39..db31f58 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -47,6 +47,7 @@ struct page_ext {
 };
 
 extern void pgdat_page_ext_init(struct pglist_data *pgdat);
+extern void __init invoke_init_callbacks(void);
 
 #ifdef CONFIG_SPARSEMEM
 static inline void page_ext_init_flatmem(void)
@@ -57,6 +58,7 @@ static inline void page_ext_init_flatmem(void)
 extern void page_ext_init_flatmem(void);
 static inline void page_ext_init(void)
 {
+       invoke_init_callbacks();
 }
 #endif
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 121dcff..a405869 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -91,7 +91,7 @@ static bool __init invoke_need_callbacks(void)
        return need;
 }
 
-static void __init invoke_init_callbacks(void)
+void __init invoke_init_callbacks(void)
 {
        int i;
        int entries = ARRAY_SIZE(page_ext_ops);
@@ -190,7 +190,6 @@ void __init page_ext_init_flatmem(void)
                        goto fail;
        }
        pr_info("allocated %ld bytes of page_ext\n", total_usage);
-       invoke_init_callbacks();
        return;
 
 fail:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
