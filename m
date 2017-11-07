Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E49A06B02BF
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 08:05:48 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id q4so12744297oic.12
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 05:05:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r21si345445ote.179.2017.11.07.05.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 05:05:47 -0800 (PST)
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
References: <20171105231850.5e313e46@roar.ozlabs.ibm.com>
 <871slcszfl.fsf@linux.vnet.ibm.com>
 <20171106174707.19f6c495@roar.ozlabs.ibm.com>
 <24b93038-76f7-33df-d02e-facb0ce61cd2@redhat.com>
 <20171106192524.12ea3187@roar.ozlabs.ibm.com>
 <d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com>
 <546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com>
 <20171107160705.059e0c2b@roar.ozlabs.ibm.com>
 <20171107111543.ep57evfxxbwwlhdh@node.shutemov.name>
 <c5586546-1e7e-0f0f-a8b3-680fadb38dcf@redhat.com>
 <20171107114422.bgnm5k6w2zqjoazc@node.shutemov.name>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <7fc1641b-361c-2ee2-c510-f7c64d173bf8@redhat.com>
Date: Tue, 7 Nov 2017 14:05:42 +0100
MIME-Version: 1.0
In-Reply-To: <20171107114422.bgnm5k6w2zqjoazc@node.shutemov.name>
Content-Type: multipart/mixed;
 boundary="------------381B9005558AE185EB668BF2"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------381B9005558AE185EB668BF2
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 11/07/2017 12:44 PM, Kirill A. Shutemov wrote:
> On Tue, Nov 07, 2017 at 12:26:12PM +0100, Florian Weimer wrote:
>> On 11/07/2017 12:15 PM, Kirill A. Shutemov wrote:
>>
>>>> First of all, using addr and MAP_FIXED to develop our heuristic can
>>>> never really give unchanged ABI. It's an in-band signal. brk() is a
>>>> good example that steadily keeps incrementing address, so depending
>>>> on malloc usage and address space randomization, you will get a brk()
>>>> that ends exactly at 128T, then the next one will be >
>>>> DEFAULT_MAP_WINDOW, and it will switch you to 56 bit address space.
>>>
>>> No, it won't. You will hit stack first.
>>
>> That's not actually true on POWER in some cases.  See the process maps I
>> posted here:
>>
>>    <https://marc.info/?l=linuxppc-embedded&m=150988538106263&w=2>
> 
> Hm? I see that in all three cases the [stack] is the last mapping.
> Do I miss something?

Hah, I had not noticed.  Occasionally, the order of heap and stack is 
reversed.  This happens in approximately 15% of the runs.

See the attached example.

Thanks,
Florian

--------------381B9005558AE185EB668BF2
Content-Type: text/plain; charset=UTF-8;
 name="maps.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="maps.txt"

N2ZmZmFjYzUwMDAwLTdmZmZhY2M5MDAwMCBydy1wIDAwMDAwMDAwIDAwOjAwIDAgCjdmZmZh
Y2M5MDAwMC03ZmZmYWNjZjAwMDAgci0tcCAwMDAwMDAwMCBmZDowMCAyNTE2NzkyNSAgICAg
ICAgICAgICAgICAgICAvdXNyL2xpYi9sb2NhbGUvZW5fVVMudXRmOC9MQ19DVFlQRQo3ZmZm
YWNjZjAwMDAtN2ZmZmFjZDAwMDAwIHItLXAgMDAwMDAwMDAgZmQ6MDAgMjUxNjc5MjggICAg
ICAgICAgICAgICAgICAgL3Vzci9saWIvbG9jYWxlL2VuX1VTLnV0ZjgvTENfTlVNRVJJQwo3
ZmZmYWNkMDAwMDAtN2ZmZmFjZDEwMDAwIHItLXAgMDAwMDAwMDAgZmQ6MDAgMTY3OTg5Mjkg
ICAgICAgICAgICAgICAgICAgL3Vzci9saWIvbG9jYWxlL2VuX1VTLnV0ZjgvTENfVElNRQo3
ZmZmYWNkMTAwMDAtN2ZmZmFjZTQwMDAwIHItLXAgMDAwMDAwMDAgZmQ6MDAgMjUxNjc5MjQg
ICAgICAgICAgICAgICAgICAgL3Vzci9saWIvbG9jYWxlL2VuX1VTLnV0ZjgvTENfQ09MTEFU
RQo3ZmZmYWNlNDAwMDAtN2ZmZmFjZTUwMDAwIHItLXAgMDAwMDAwMDAgZmQ6MDAgMTY3OTg5
MjcgICAgICAgICAgICAgICAgICAgL3Vzci9saWIvbG9jYWxlL2VuX1VTLnV0ZjgvTENfTU9O
RVRBUlkKN2ZmZmFjZTUwMDAwLTdmZmZhY2U2MDAwMCByLS1wIDAwMDAwMDAwIGZkOjAwIDI1
MTEgICAgICAgICAgICAgICAgICAgICAgIC91c3IvbGliL2xvY2FsZS9lbl9VUy51dGY4L0xD
X01FU1NBR0VTL1NZU19MQ19NRVNTQUdFUwo3ZmZmYWNlNjAwMDAtN2ZmZmFjZTcwMDAwIHIt
LXAgMDAwMDAwMDAgZmQ6MDAgMTY3OTg5NDIgICAgICAgICAgICAgICAgICAgL3Vzci9saWIv
bG9jYWxlL2VuX1VTLnV0ZjgvTENfUEFQRVIKN2ZmZmFjZTcwMDAwLTdmZmZhY2U4MDAwMCBy
LS1wIDAwMDAwMDAwIGZkOjAwIDI1MTY3OTI3ICAgICAgICAgICAgICAgICAgIC91c3IvbGli
L2xvY2FsZS9lbl9VUy51dGY4L0xDX05BTUUKN2ZmZmFjZTgwMDAwLTdmZmZhY2U5MDAwMCBy
LS1wIDAwMDAwMDAwIGZkOjAwIDE2Nzk4OTI0ICAgICAgICAgICAgICAgICAgIC91c3IvbGli
L2xvY2FsZS9lbl9VUy51dGY4L0xDX0FERFJFU1MKN2ZmZmFjZTkwMDAwLTdmZmZhY2VhMDAw
MCByLS1wIDAwMDAwMDAwIGZkOjAwIDE2Nzk4OTI4ICAgICAgICAgICAgICAgICAgIC91c3Iv
bGliL2xvY2FsZS9lbl9VUy51dGY4L0xDX1RFTEVQSE9ORQo3ZmZmYWNlYTAwMDAtN2ZmZmFj
ZWIwMDAwIHItLXAgMDAwMDAwMDAgZmQ6MDAgMTY3OTg5MjYgICAgICAgICAgICAgICAgICAg
L3Vzci9saWIvbG9jYWxlL2VuX1VTLnV0ZjgvTENfTUVBU1VSRU1FTlQKN2ZmZmFjZWIwMDAw
LTdmZmZhY2VjMDAwMCByLS1zIDAwMDAwMDAwIGZkOjAwIDgzOTA2NTcgICAgICAgICAgICAg
ICAgICAgIC91c3IvbGliNjQvZ2NvbnYvZ2NvbnYtbW9kdWxlcy5jYWNoZQo3ZmZmYWNlYzAw
MDAtN2ZmZmFkMGQwMDAwIHIteHAgMDAwMDAwMDAgZmQ6MDAgODM5MDMzNSAgICAgICAgICAg
ICAgICAgICAgL3Vzci9saWI2NC9saWJjLTIuMjUuc28KN2ZmZmFkMGQwMDAwLTdmZmZhZDBl
MDAwMCAtLS1wIDAwMjEwMDAwIGZkOjAwIDgzOTAzMzUgICAgICAgICAgICAgICAgICAgIC91
c3IvbGliNjQvbGliYy0yLjI1LnNvCjdmZmZhZDBlMDAwMC03ZmZmYWQwZjAwMDAgci0tcCAw
MDIxMDAwMCBmZDowMCA4MzkwMzM1ICAgICAgICAgICAgICAgICAgICAvdXNyL2xpYjY0L2xp
YmMtMi4yNS5zbwo3ZmZmYWQwZjAwMDAtN2ZmZmFkMTAwMDAwIHJ3LXAgMDAyMjAwMDAgZmQ6
MDAgODM5MDMzNSAgICAgICAgICAgICAgICAgICAgL3Vzci9saWI2NC9saWJjLTIuMjUuc28K
N2ZmZmFkMTAwMDAwLTdmZmZhZDExMDAwMCByLS1wIDAwMDAwMDAwIGZkOjAwIDE2Nzk4OTI1
ICAgICAgICAgICAgICAgICAgIC91c3IvbGliL2xvY2FsZS9lbl9VUy51dGY4L0xDX0lERU5U
SUZJQ0FUSU9OCjdmZmZhZDExMDAwMC03ZmZmYWQxMjAwMDAgci14cCAwMDAwMDAwMCBmZDow
MCA2MzU0MyAgICAgICAgICAgICAgICAgICAgICAvdXNyL2Jpbi9jYXQKN2ZmZmFkMTIwMDAw
LTdmZmZhZDEzMDAwMCByLS1wIDAwMDAwMDAwIGZkOjAwIDYzNTQzICAgICAgICAgICAgICAg
ICAgICAgIC91c3IvYmluL2NhdAo3ZmZmYWQxMzAwMDAtN2ZmZmFkMTQwMDAwIHJ3LXAgMDAw
MTAwMDAgZmQ6MDAgNjM1NDMgICAgICAgICAgICAgICAgICAgICAgL3Vzci9iaW4vY2F0Cjdm
ZmZhZDE0MDAwMC03ZmZmYWQxNjAwMDAgci14cCAwMDAwMDAwMCAwMDowMCAwICAgICAgICAg
ICAgICAgICAgICAgICAgICBbdmRzb10KN2ZmZmFkMTYwMDAwLTdmZmZhZDFhMDAwMCByLXhw
IDAwMDAwMDAwIGZkOjAwIDgzOTAzMjggICAgICAgICAgICAgICAgICAgIC91c3IvbGliNjQv
bGQtMi4yNS5zbwo3ZmZmYWQxYTAwMDAtN2ZmZmFkMWIwMDAwIHItLXAgMDAwMzAwMDAgZmQ6
MDAgODM5MDMyOCAgICAgICAgICAgICAgICAgICAgL3Vzci9saWI2NC9sZC0yLjI1LnNvCjdm
ZmZhZDFiMDAwMC03ZmZmYWQxYzAwMDAgcnctcCAwMDA0MDAwMCBmZDowMCA4MzkwMzI4ICAg
ICAgICAgICAgICAgICAgICAvdXNyL2xpYjY0L2xkLTIuMjUuc28KN2ZmZmMyY2YwMDAwLTdm
ZmZjMmQyMDAwMCBydy1wIDAwMDAwMDAwIDAwOjAwIDAgICAgICAgICAgICAgICAgICAgICAg
ICAgIFtzdGFja10KN2ZmZmM4YzEwMDAwLTdmZmZjOGM0MDAwMCBydy1wIDAwMDAwMDAwIDAw
OjAwIDAgICAgICAgICAgICAgICAgICAgICAgICAgIFtoZWFwXQo=
--------------381B9005558AE185EB668BF2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
