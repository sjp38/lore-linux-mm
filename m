Received: by rv-out-0910.google.com with SMTP id f1so3353853rvb.26
        for <linux-mm@kvack.org>; Sat, 01 Mar 2008 02:29:44 -0800 (PST)
Message-ID: <84144f020803010229l7ad52a82o42a06d4de2bf6035@mail.gmail.com>
Date: Sat, 1 Mar 2008 12:29:44 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 3/8] slub: Update statistics handling for variable order slabs
In-Reply-To: <20080229044818.999367120@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080229044803.482012397@sgi.com>
	 <20080229044818.999367120@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Fri, Feb 29, 2008 at 9:43 PM, Christoph Lameter <clameter@sgi.com> wrote:
>  Hmmm... I get some weird numbers when I use slabinfo but cannot spot the
>  issue. Could you look a bit closer at this? In particular at the slabinfo
>  emulation?

What kind of weird numbers? Unfortunately the patch still looks
correct to me so it might be an integer overflow issue...

On Fri, Feb 29, 2008 at 6:48 AM, Christoph Lameter <clameter@sgi.com> wrote:
>  @@ -4331,7 +4367,9 @@ static int s_show(struct seq_file *m, vo
>         unsigned long nr_partials = 0;

nr_partials is no longer read so you can remove it.

>         unsigned long nr_slabs = 0;
>         unsigned long nr_inuse = 0;

No need to initialize nr_inuse to zero here.

>  -       unsigned long nr_objs;
>  +       unsigned long nr_objs = 0;
>  +       unsigned long nr_partial_inuse = 0;
>  +       unsigned long nr_partial_total = 0;
>         struct kmem_cache *s;
>         int node;
>
>  @@ -4345,14 +4383,15 @@ static int s_show(struct seq_file *m, vo
>
>                 nr_partials += n->nr_partial;
>                 nr_slabs += atomic_long_read(&n->nr_slabs);
>  -               nr_inuse += count_partial(n);
>  +               nr_objs += atomic_long_read(&n->total_objects);

So does ->total_objects contain the total amount of objects (not
necessarily in use) including the partial list or not? AFAICT it
_does_ include slabs in the partial list too so nr_objs is correct
here.

>  +               nr_partial_inuse += count_partial_inuse(n);
>  +               nr_partial_total += count_partial_total(s, n);
>         }
>
>  -       nr_objs = nr_slabs * s->objects;
>  -       nr_inuse += (nr_slabs - nr_partials) * s->objects;
>  +       nr_inuse = nr_objs - (nr_partial_total - nr_partial_inuse);

So if nr_objs contains the total number of objects in all slabs
including those that are in the partial list, this looks correct also.

                             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
