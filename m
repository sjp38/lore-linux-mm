Received: by nproxy.gmail.com with SMTP id l35so53794nfa
        for <linux-mm@kvack.org>; Wed, 25 Jan 2006 23:41:28 -0800 (PST)
Message-ID: <84144f020601252341k62c0c6fck57f3baa290f4430@mail.gmail.com>
Date: Thu, 26 Jan 2006 09:41:27 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 8/9] slab - Add *_mempool slab variants
In-Reply-To: <1138218020.2092.8.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060125161321.647368000@localhost.localdomain>
	 <1138218020.2092.8.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Matthew,

On 1/25/06, Matthew Dobson <colpatch@us.ibm.com> wrote:
> +extern void *__kmalloc(size_t, gfp_t, mempool_t *);

If you really need to do this, please ntoe that you're adding an extra
parameter push for the nominal case where mempool is not required. The
compiler is unable to optimize it away. It's better that you create a
new entry point for the mempool case in mm/slab.c rather than
overloading __kmalloc() et al. See the following patch that does that
sort of thing:

http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.16-rc1/2.6.16-rc1-mm3/broken-out/slab-fix-kzalloc-and-kstrdup-caller-report-for-config_debug_slab.patch

Now as for the rest of the patch, are you sure you want to reserve
whole pages for each critical allocation that cannot be satisfied by
the slab allocator? Wouldn't it be better to use something like the
slob allocator to allocate from the mempool pages? That way you
wouldn't have to make the slab allocator mempool aware at all, simply
make your kmalloc_mempool first try the slab allocator and if it
returns NULL, go for the critical pool. All this in preferably
separate file so you don't make mm/slab.c any more complex than it is
now.

                                            Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
