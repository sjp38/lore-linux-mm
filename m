Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 2F9096B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 06:00:06 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so5029462bkc.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 03:00:04 -0700 (PDT)
Message-ID: <501A4FC1.8040907@gmail.com>
Date: Thu, 02 Aug 2012 12:00:33 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
References: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com> <1343757920-19713-2-git-send-email-levinsasha928@gmail.com> <20120731182330.GD21292@google.com> <50197348.9010101@gmail.com> <20120801182112.GC15477@google.com> <50197460.8010906@gmail.com> <20120801182749.GD15477@google.com> <50197E4A.7020408@gmail.com> <20120801202432.GE15477@google.com> <5019B0B4.1090102@gmail.com> <20120801224556.GF15477@google.com>
In-Reply-To: <20120801224556.GF15477@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, josh@joshtriplett.org

On 08/02/2012 12:45 AM, Tejun Heo wrote:
> On Thu, Aug 02, 2012 at 12:41:56AM +0200, Sasha Levin wrote:
>> How would your DEFINE_HASHTABLE look like if we got for the simple
>> 'struct hash_table' approach?
> 
> I think defining a different enclosing anonymous struct which the
> requested number of array entries and then aliasing the actual
> hash_table to that symbol should work.  It's rather horrible and I'm
> not sure it's worth the trouble.

I agree that this is probably not worth the trouble.

At the moment I see two alternatives:

1. Dynamically allocate the hash buckets.

2. Use the first bucket to store size. Something like the follows:

	#define HASH_TABLE(name, bits)	\
        	struct hlist_head name[1 << bits + 1];

	#define HASH_TABLE_INIT (bits) ({name[0].next = bits});

And then have hash_{add,get} just skip the first bucket.


While it's not a pretty hack, I don't see a nice way to avoid having to dynamically allocate buckets for all cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
