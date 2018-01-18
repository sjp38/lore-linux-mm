Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D95C6B0069
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 16:36:05 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 34so8756478uaq.11
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 13:36:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z36sor3311304uaz.148.2018.01.18.13.36.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 13:36:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <19a7add8-adaf-4ad4-6ae3-4a62967656b9@redhat.com>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
 <1515636190-24061-28-git-send-email-keescook@chromium.org> <19a7add8-adaf-4ad4-6ae3-4a62967656b9@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 18 Jan 2018 13:36:03 -0800
Message-ID: <CAGXu5jK_VyEM4-MaQ53o2AS8NNiTyR8X5LUrbwd=KcDWfKhGTg@mail.gmail.com>
Subject: Re: [PATCH 27/38] sctp: Copy struct sctp_sock.autoclose to userspace
 using put_user()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, Vlad Yasevich <vyasevich@gmail.com>, Neil Horman <nhorman@tuxdriver.com>, "David S. Miller" <davem@davemloft.net>, linux-sctp@vger.kernel.org, Network Development <netdev@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com

On Thu, Jan 18, 2018 at 1:31 PM, Laura Abbott <labbott@redhat.com> wrote:
> On 01/10/2018 06:02 PM, Kees Cook wrote:
>>
>> From: David Windsor <dave@nullcore.net>
>>
>> The autoclose field can be copied with put_user(), so there is no need to
>> use copy_to_user(). In both cases, hardened usercopy is being bypassed
>> since the size is constant, and not open to runtime manipulation.
>>
>> This patch is verbatim from Brad Spengler/PaX Team's PAX_USERCOPY
>> whitelisting code in the last public patch of grsecurity/PaX based on my
>> understanding of the code. Changes or omissions from the original code are
>> mine and don't reflect the original grsecurity/PaX code.
>>
>
> Just tried a quick rebase and it looks like this conflicts with
> c76f97c99ae6 ("sctp: make use of pre-calculated len")
> I don't think we can use put_user if we're copying via the full
> len?

It should be fine, since:

        len = sizeof(int);

c76f97c99ae6 just does a swap of sizeof(int) with len, put_user() will
work in either case, since autoclose will always be int sized.

-Kees

>
> Thanks,
> Laura
>
>
>> Signed-off-by: David Windsor <dave@nullcore.net>
>> [kees: adjust commit log]
>> Cc: Vlad Yasevich <vyasevich@gmail.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: linux-sctp@vger.kernel.org
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>>   net/sctp/socket.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index efbc8f52c531..15491491ec88 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -5011,7 +5011,7 @@ static int sctp_getsockopt_autoclose(struct sock
>> *sk, int len, char __user *optv
>>         len = sizeof(int);
>>         if (put_user(len, optlen))
>>                 return -EFAULT;
>> -       if (copy_to_user(optval, &sctp_sk(sk)->autoclose, sizeof(int)))
>> +       if (put_user(sctp_sk(sk)->autoclose, (int __user *)optval))
>>                 return -EFAULT;
>>         return 0;
>>   }
>>
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
