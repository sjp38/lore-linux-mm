Date: Wed, 12 Nov 2008 16:07:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 1/6] memcg: free all at rmdir
Message-Id: <20081112160758.3dca0b22.akpm@linux-foundation.org>
In-Reply-To: <20081112122656.c6e56248.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112122656.c6e56248.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, menage@google.com
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008 12:26:56 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> +5.1 on_rmdir
> +set behavior of memcg at rmdir (Removing cgroup) default is "drop".
> +
> +5.1.1 drop
> +       #echo on_rmdir drop > memory.attribute
> +       This is default. All pages on the memcg will be freed.
> +       If pages are locked or too busy, they will be moved up to the parent.
> +       Useful when you want to drop (large) page caches used in this memcg.
> +       But some of in-use page cache can be dropped by this.
> +
> +5.1.2 keep
> +       #echo on_rmdir keep > memory.attribute
> +       All pages on the memcg will be moved to its parent.
> +       Useful when you don't want to drop page caches used in this memcg.
> +       You can keep page caches from some library or DB accessed by this
> +       memcg on memory.

Would it not be more useful to implement a per-memcg version of
/proc/sys/vm/drop_caches?  (One without drop_caches' locking bug,
hopefully).

If we do this then we can make the above "keep" behaviour non-optional,
and the operator gets to choose whether or not to drop the caches
before doing the rmdir.

Plus, we get a new per-memcg drop_caches capability.  And it's a nicer
interface, and it doesn't have the obvious races which on_rmdir has,
etc.

hm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
