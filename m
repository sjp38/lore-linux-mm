Received: by wx-out-0506.google.com with SMTP id h31so207198wxd
        for <linux-mm@kvack.org>; Wed, 19 Sep 2007 01:37:22 -0700 (PDT)
Message-ID: <57d8e7a0709190137v3d90d8e4r40eb254b657e9a94@mail.gmail.com>
Date: Wed, 19 Sep 2007 09:37:21 +0100
From: "John Berthels" <jjberthels@gmail.com>
Subject: Re: [PATCH][RESEND] maps: PSS(proportional set size) accounting in smaps
In-Reply-To: <20070917161027.GY4219@waste.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <389996856.30386@ustc.edu.cn>
	 <20070916235120.713c6102.akpm@linux-foundation.org>
	 <20070917161027.GY4219@waste.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <wfg@mail.ustc.edu.cn>, Balbir Singh <balbir@linux.vnet.ibm.com>, Denys Vlasenko <vda.linux@googlemail.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 17/09/2007, Matt Mackall <mpm@selenic.com> wrote:
> The big downside to PSS is that it's expensive to track. We have to
> either visit each page when we report the count or we have to update
> each PSS counter when we change the use count on a shared page. There
> might be some tricks we can pull here but RSS and VSS, on the other
> hand, are effectively O(1). An efficient in-kernel PSS calculator
> might be a little painful if used in something like top(1), but the
> map2 approach definitely won't be fast enough here.

This is the advantage of exmap/pagemap. You don't pay any runtime penalty.

Personally, I'd probably rather make do with RSS and VSS to see which
processes are 'large'. There usually aren't many.

If there's a significant/measurable penalty to tracking PSS in kernel
I'd say why bother? It's a very useful number *when you are interested
in it*. On those occasions you can fire up the more complex tool and
pay the time to walk the page tables. It's not a very dynamic
quantity, so a snapshotting approach works well.

Also exmap (I don't know if pagemap does this) grovels through ELF and
/proc/<pid>/maps so you can see which section+symbol of your shared
lib is hurting you. You're generally going to want this info in order
to do anything about bad PSS numbers, so I'm not sure raw PSS numbers
are directly useful.

Is map2 -mm tree only (I didn't get anything on a grep of mainline
2.6.22.6)? Sorry, I'm a bit out of touch. If I could drop the kernel
module from exmap and use an existing interface that would be great.

jb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
