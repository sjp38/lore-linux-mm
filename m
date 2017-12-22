Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9385E6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 22:18:26 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id 207so9543652iti.5
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 19:18:26 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id e2si6010120itf.115.2017.12.21.19.18.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 19:18:25 -0800 (PST)
Subject: Re: [PATCH] Move kfree_call_rcu() to slab_common.c
References: <1513844387-2668-1-git-send-email-rao.shoaib@oracle.com>
 <20171221123630.GB22405@bombadil.infradead.org>
 <44044955-1ef9-1d1e-5311-d8edc006b812@oracle.com>
 <20171222013937.GA7829@linux.vnet.ibm.com>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <106f9cdb-bb0b-539d-547e-18c509ca1163@oracle.com>
Date: Thu, 21 Dec 2017 19:17:35 -0800
MIME-Version: 1.0
In-Reply-To: <20171222013937.GA7829@linux.vnet.ibm.com>
Content-Type: multipart/alternative;
 boundary="------------59C28A6D52A0CCD0686C9CAF"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, brouer@redhat.com, linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------59C28A6D52A0CCD0686C9CAF
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit



On 12/21/2017 05:39 PM, Paul E. McKenney wrote:
>> I left it out on purpose because the call in tiny is a little different
>>
>> rcutiny.h:
>>
>> static inline void kfree_call_rcu(struct rcu_head *head,
>>  A A A  A A A  A A A  A A A  A  void (*func)(struct rcu_head *rcu))
>> {
>>  A A A  call_rcu(head, func);
>> }
>>
>> tree.c:
>>
>> void kfree_call_rcu(struct rcu_head *head,
>>  A A A  A A A  A A A  void (*func)(struct rcu_head *rcu))
>> {
>>  A A A  __call_rcu(head, func, rcu_state_p, -1, 1);
>> }
>> EXPORT_SYMBOL_GPL(kfree_call_rcu);
>>
>> If we want the code to be exactly same I can create a lazy version
>> for tiny as well. However,A  I don not know where to move
>> kfree_call_rcu() from it's current home in rcutiny.h though. Any
>> thoughts ?
> I might be missing something subtle here, but in case I am not, my
> suggestion is to simply rename rcutiny.h's kfree_call_rcu() and otherwise
> leave it as is.  If you want to update the type of the second argument,
> which got missed back in the day, there is always this:
>
> static inline void call_rcu_lazy(struct rcu_head *head, rcu_callback_t func)
> {
> 	call_rcu(head, func);
> }
>
> The reason that Tiny RCU doesn't handle laziness specially is because
> Tree RCU's handling of laziness is a big no-op on the single CPU systems
> on which Tiny RCU runs.  So Tiny RCU need do nothing special to support
> laziness.
>
> 							Thanx, Paul
>
Hi Paul,

I can not just change the name as __kfree_call_rcu macro calls 
kfree_call_rcu(). I have made tiny version of kfree_call_rcu() call 
rcu_call_lazy() which calls call_rcu(). As far as the type is concerned, 
my bad, I cut and posted from an older release. Latest code is already 
using the typedef.

Shoaib

--------------59C28A6D52A0CCD0686C9CAF
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p><br>
    </p>
    <br>
    <div class="moz-cite-prefix">On 12/21/2017 05:39 PM, Paul E.
      McKenney wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:20171222013937.GA7829@linux.vnet.ibm.com">
      <blockquote type="cite" style="color: #000000;">
        <pre wrap="">I left it out on purpose because the call in tiny is a little different

rcutiny.h:

static inline void kfree_call_rcu(struct rcu_head *head,
A A A  A A A  A A A  A A A  A  void (*func)(struct rcu_head *rcu))
{
A A A  call_rcu(head, func);
}

tree.c:

void kfree_call_rcu(struct rcu_head *head,
A A A  A A A  A A A  void (*func)(struct rcu_head *rcu))
{
A A A  __call_rcu(head, func, rcu_state_p, -1, 1);
}
EXPORT_SYMBOL_GPL(kfree_call_rcu);

If we want the code to be exactly same I can create a lazy version
for tiny as well. However,A  I don not know where to move
kfree_call_rcu() from it's current home in rcutiny.h though. Any
thoughts ?
</pre>
      </blockquote>
      <pre wrap="">I might be missing something subtle here, but in case I am not, my
suggestion is to simply rename rcutiny.h's kfree_call_rcu() and otherwise
leave it as is.  If you want to update the type of the second argument,
which got missed back in the day, there is always this:

static inline void call_rcu_lazy(struct rcu_head *head, rcu_callback_t func)
{
	call_rcu(head, func);
}

The reason that Tiny RCU doesn't handle laziness specially is because
Tree RCU's handling of laziness is a big no-op on the single CPU systems
on which Tiny RCU runs.  So Tiny RCU need do nothing special to support
laziness.

							Thanx, Paul

</pre>
    </blockquote>
    Hi Paul,<br>
    <br>
    I can not just change the name as __kfree_call_rcu macro calls
    kfree_call_rcu(). I have made tiny version of kfree_call_rcu() call
    rcu_call_lazy() which calls call_rcu(). As far as the type is
    concerned, my bad, I cut and posted from an older release. Latest
    code is already using the typedef.<br>
    <br>
    Shoaib<br>
  </body>
</html>

--------------59C28A6D52A0CCD0686C9CAF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
