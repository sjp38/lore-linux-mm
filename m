Subject: Re: [RFC] per thread page reservation patch
References: <20050103011113.6f6c8f44.akpm@osdl.org>
	<20050103114854.GA18408@infradead.org> <41DC2386.9010701@namesys.com>
	<1105019521.7074.79.camel@tribesman.namesys.com>
	<20050107144644.GA9606@infradead.org>
	<1105118217.3616.171.camel@tribesman.namesys.com>
	<20050107104838.0eacd301.akpm@osdl.org>
From: Nikita Danilov <nikita@clusterfs.com>
Date: Fri, 07 Jan 2005 23:21:19 +0300
In-Reply-To: <20050107104838.0eacd301.akpm@osdl.org> (Andrew Morton's
 message of "Fri, 7 Jan 2005 10:48:38 -0800")
Message-ID: <m1u0ptq9c0.fsf@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> writes:

> Vladimir Saveliev <vs@namesys.com> wrote:
>>
>> +int perthread_pages_reserve(int nrpages, int gfp)
>>  +{
>>  +	int i;
>>  +	struct list_head  accumulator;
>>  +	struct list_head *per_thread;
>>  +
>>  +	per_thread = get_per_thread_pages();
>>  +	INIT_LIST_HEAD(&accumulator);
>>  +	list_splice_init(per_thread, &accumulator);
>>  +	for (i = 0; i < nrpages; ++i) {
>
> This will end up reserving more pages than were asked for, if
> current->private_pages_count is non-zero.  Deliberate?

Yes. This is to make modular usage possible, so that


        perthread_pages_reserve(nrpages, gfp_mask);

        /* call some other code... */

        perthread_pages_release(unused_pages);

works correctly if "some other code" does per-thread reservations
too.

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
