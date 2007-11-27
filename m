From: pageexec@freemail.hu
Date: Wed, 28 Nov 2007 00:01:57 +0200
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm: Prevent dereferencing non-allocated per_cpu variables
Reply-to: pageexec@freemail.hu
Message-ID: <474CAFF5.8792.356C2F62@pageexec.freemail.hu>
In-reply-to: <20071127215054.660250000@sgi.com>
References: <20071127215052.090968000@sgi.com>, <20071127215054.660250000@sgi.com>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, travis@sgi.com
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 27 Nov 2007 at 13:50, travis@sgi.com wrote:

> Change loops controlled by 'for (i = 0; i < NR_CPUS; i++)' to use
> 'for_each_possible_cpu(i)' when there's a _remote possibility_ of
> dereferencing a non-allocated per_cpu variable involved.

actually, it's not that remote, it happens every time
NR_CPUS > num_possible_cpus(). i ran into this myself
on a dual core box with NR_CPUS=4. due to my rewrite
of the i386 per-cpu segment handling, i actually got
a NULL deref where the vanilla kernel would be accessing
the area of [__per_cpu_start, __per_cpu_end] for each
non-possible CPU (which doesn't crash per se but is
still not correct somehow i think).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
