Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id BF7F96B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 17:50:40 -0400 (EDT)
Received: by weys10 with SMTP id s10so12748wey.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 14:50:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120802212140.GC7916@jtriplet-mobl1>
References: <20120802103244.GA23318@leaf> <501A633B.3010509@gmail.com>
 <87txwl1dsq.fsf@xmission.com> <501AAC26.6030703@gmail.com>
 <87fw851c3d.fsf@xmission.com> <CA+55aFw_dwO5ZOuaz9eDxgnTZFDGVZKSLUTm5Fn99faALxxJRQ@mail.gmail.com>
 <20120802175904.GB6251@jtriplet-mobl1> <CA+55aFwqC9hF++S-VPHJBFRrqfyNvsvqwzP=Vtzkv8qSYVqLxA@mail.gmail.com>
 <20120802202516.GA7916@jtriplet-mobl1> <CA+55aFybtRdg=AzcHv3CPm-_wx8LT2_CXaKr4K+i94QSPauZOw@mail.gmail.com>
 <20120802212140.GC7916@jtriplet-mobl1>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 2 Aug 2012 14:50:18 -0700
Message-ID: <CA+55aFwjWBFq75uQzVekv_ZygG9Sejrf2ok-EhvfvSPxhTFzfg@mail.gmail.com>
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On Thu, Aug 2, 2012 at 2:21 PM, Josh Triplett <josh@joshtriplett.org> wrote:
>
>  Did GCC's generated code have worse differences than an immediate
>  versus a fetched value?

Oh, *way* worse.

Nobody just masks the low bits. You have more bits than the low bits,
and unless you have some cryptographic hash (seldom) you want to use
them.

So no, it's not just as mask. For the dcache, it's

        hash = hash + (hash >> D_HASHBITS);
        return dentry_hashtable + (hash & D_HASHMASK);

so it's "shift + mask", and the constants mean less register pressure
and fewer latencies. One of the advantages of the L1 dcache code is
that the code gets *so* much simpler that it doesn't need a stack save
area at all, for example.

But as mentioned, the dcache L1 patch had other simplifications than
just the hash calculations, though. It doesn't do any loop over next
fields at all (it falls back to the slow case if it isn't a direct
hit), and it doesn't care about the d_compare() case (they will never
be added to the L1, since looking those things up is so slow that
there's no point). So there are other issues at play than just
avoiding the indirection to fetch base/mask/bitcount things and the
simplified hash calculation.

Not having a loop makes the register lifetimes simpler and again
causes less register pressure.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
