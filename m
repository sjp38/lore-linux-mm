Date: Tue, 26 Oct 2004 10:01:36 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: migration cache, updated
Message-ID: <20041026120136.GC27014@logos.cnet>
References: <20041025213923.GD23133@logos.cnet> <417DA5B8.8000706@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <417DA5B8.8000706@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Hirokazu Takahashi <taka@valinux.co.jp>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 26, 2004 at 10:17:44AM +0900, Hiroyuki KAMEZAWA wrote:
> Hi, Marcelo
> 
> Marcelo Tosatti wrote:
> >Hi,
> > #define SWP_TYPE_SHIFT(e)	(sizeof(e.val) * 8 - MAX_SWAPFILES_SHIFT)
> >-#define SWP_OFFSET_MASK(e)	((1UL << SWP_TYPE_SHIFT(e)) - 1)
> >+#define SWP_OFFSET_MASK(e)	((1UL << (SWP_TYPE_SHIFT(e))) - 1)
> >+
> >+#define MIGRATION_TYPE  (MAX_SWAPFILES - 1)
> > 
> At the first glance, I think MIGRATION_TYPE=0 is better.
> #define MIGRATION_TYPE  (0)
> 
> In swapfile.c::sys_swapon()
> This code determines new swap_type for commanded swapon().
> =============
> p = swap_info;
> for (type = 0 ; type < nr_swapfiles ; type++,p++)
>          if (!(p->flags & SWP_USED))
>                break;
> error = -EPERM;
> ==============
> 
> set nr_swapfiles=1, swap_info[0].flags = SWP_USED
> at boot time seems good. or fix swapon().

Hi Hiroyuki,

Indeed.

This should do it?

--- swapfile.c.orig     2004-10-26 11:33:56.734551048 -0200
+++ swapfile.c  2004-10-26 11:34:03.284555296 -0200
@@ -1370,6 +1370,13 @@ asmlinkage long sys_swapon(const char __
                swap_list_unlock();
                goto out;
        }
+
+       /* MAX_SWAPFILES-1 is reserved for migration pages */
+       if (type > MAX_SWAPFILES-1) {
+               swap_list_unlock();
+               goto out;
+       }
+
        if (type >= nr_swapfiles)
                nr_swapfiles = type+1;
        INIT_LIST_HEAD(&p->extent_list);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
