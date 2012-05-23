Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 7E8326B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 10:29:01 -0400 (EDT)
Received: by yhr47 with SMTP id 47so9510626yhr.14
        for <linux-mm@kvack.org>; Wed, 23 May 2012 07:29:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205221240530.21828@router.home>
References: <20120518161906.207356777@linux.com>
	<20120518161927.549888128@linux.com>
	<CAAmzW4O2zk5K3StnGXcQmvDqfSDQbmezoVLYsH-3s4mE9WaEBA@mail.gmail.com>
	<alpine.DEB.2.00.1205221240530.21828@router.home>
Date: Wed, 23 May 2012 23:28:58 +0900
Message-ID: <CAAmzW4MqGKgz7YDcX4S1jQPtdAmHkiAfCNcFKTg35gP=qjqgHQ@mail.gmail.com>
Subject: Re: [RFC] Common code 01/12] [slob] define page struct fields used in mm_types.h
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

>> > +static inline void clear_slob_page_free(struct page *sp)
>> > =A0{
>> > =A0 =A0 =A0 =A0list_del(&sp->list);
>> > - =A0 =A0 =A0 __ClearPageSlobFree((struct page *)sp);
>> > + =A0 =A0 =A0 __ClearPageSlobFree(sp);
>> > =A0}
>>
>> I think we shouldn't use __ClearPageSlobFree anymore.
>> Before this patch, list_del affect page->private,
>> so when we manipulate slob list,
>> using PageSlobFree overloaded with PagePrivate is reasonable.
>> But, after this patch is applied, list_del doesn't touch page->private,
>> so manipulate PageSlobFree is not reasonable.
>> We would use another method for checking slob_page_free without
>> PageSlobFree flag.
>
> What method should we be using?

Actually, I have no good idea.
How about below implementation?

static inline int slob_page_free(struct page *sp)
{
        return !list_empty(&sp->list);
}

static void set_slob_page_free(struct page *sp, struct list_head *list)
{
        list_add(&sp->list, list);
}

static inline void clear_slob_page_free(struct page *sp)
{
        list_del_init(&sp->list);
}

Above functions' name should be changed something like "add_freelist,
remove_freelist, in_freelist" for readability

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
