Date: Fri, 14 Nov 2003 17:01:01 -0800
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: 2.6.0-test9-mm3
Message-ID: <20031115010101.GA1331@mis-mike-wstn.matchmail.com>
References: <20031112233002.436f5d0c.akpm@osdl.org> <98290000.1068836914@flay> <20031114105947.641335f5.akpm@osdl.org> <20031114193249.GM2014@mis-mike-wstn.matchmail.com> <16309.14997.961879.421597@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16309.14997.961879.421597@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Stoffel <stoffel@lucent.com>
Cc: Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 14, 2003 at 03:27:01PM -0500, John Stoffel wrote:
> You don't want to grow N too aggresively, or base it on the memory of
> the system, do you?  When you have a 20mb journal, maybe starting
> writeout after 10mb is used makes sense, because you've only got 10
> transaction slots open.  But when you have a 200mb journal, does it
> make sense to start writeout when you only have 100 transaction slots
> left?  

The minimum transaction size is one block (since ext3 is the only journaling
FS to log entire blocks, instead of the specific logical changes made during
the transaction), and your blocks are 1k, 2k, or 4k.

Though many times you'll have several blocks per transaction since each
transaction can change bitmaps, directory blocks, and etc.

> Since I don't know the internals of Ext3 at all, I'm probably
> completely missing the idea here, but my gut feeling is that the
> scaling we use in these cases shouldn't be linear at all, but more
> likely inverse logyrythmic instead.  Basically, the larger we get with
> a resource, the slower we grow our useage, or the smaller we grow the
> absolute size of the writeout buffer(s).
> 
> Hmmm... this doesn't sound clear even to me.  But the idea I think I'm
> trying to get at is that if we have X size of a journal, we want to
> start writeout when we have X/2 available.  But when we have Y size of
> a journal, where Y is X*10 (or larger), we don't want Y/2 as the
> cutover point, we want something like  Y/10.  The idea is that we grow
> the denominator here at a slow rate, since it will shrink the free
> buffer percentage nicely, yet not let us get too close to a truly zero
> sized buffer.

Last I heard, ext3 will try to flush the journal with an async process and
if that isn't able to keep up, once the journal hits 50% full, the system
will write syncronously until the journal is empty (or was that until it was
25% full or less, I forget...).

AFAIK everyone agrees that this is not optimal, but nobody's taken the time
to fix it yet either.

Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
