Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 7A32C6B0005
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 18:43:33 -0500 (EST)
Date: Thu, 31 Jan 2013 15:43:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Page allocation failure on v3.8-rc5
Message-Id: <20130131154331.09d157a3.akpm@linux-foundation.org>
In-Reply-To: <CACVXFVOATzTJq+-5M9j3G3y_WUrWKJt=naPkjkLwGDmT0H8gog@mail.gmail.com>
References: <20130128091039.GG6871@arwen.pp.htv.fi>
	<CACVXFVOATzTJq+-5M9j3G3y_WUrWKJt=naPkjkLwGDmT0H8gog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: balbi@ti.com, Linux USB Mailing List <linux-usb@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>

On Wed, 30 Jan 2013 19:53:22 +0800
Ming Lei <ming.lei@canonical.com> wrote:

> The allocation failure is caused by the big sizeof(struct parsed_partitions),
> which is 64K in my 32bit box,

Geeze.

We could fix that nicely by making parsed_partitions.parts an array of
pointers to a single `struct parsed_partition' and allocating those
on-demand.

But given the short-lived nature of this storage and the infrequency of
check_partition(), that isn't necessary.

> could you test the blow patch to see
> if it can fix the allocation failure?

(The patch is wordwrapped)

> ...
>
> @@ -106,18 +107,43 @@ static int (*check_part[])(struct parsed_partitions *) = {
>  	NULL
>  };
> 
> +struct parsed_partitions *allocate_partitions(int nr)
> +{
> +	struct parsed_partitions *state;
> +
> +	state = kzalloc(sizeof(struct parsed_partitions), GFP_KERNEL);

I personally prefer sizefo(*state) here.  It means the reader doesn't
have to scroll back to check things.

> +	if (!state)
> +		return NULL;
> +
> +	state->parts = vzalloc(nr * sizeof(state->parts[0]));
> +	if (!state->parts) {
> +		kfree(state);
> +		return NULL;
> +	}

It doesn't really need to be this complex - we could just vmalloc the
entire `struct parsed_partitions'.  But I see that your change will
cause us to allcoate much less memory in many situations, which is
good.  It should be mentioned in the changelog!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
