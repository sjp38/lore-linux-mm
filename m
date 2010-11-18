Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5A8F36B0089
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 22:46:47 -0500 (EST)
Received: by iwn4 with SMTP id 4so317693iwn.14
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 19:46:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4CE49C8B.2050005@redhat.com>
References: <20101109162525.BC87.A69D9226@jp.fujitsu.com>
	<877hgmr72o.fsf@gmail.com>
	<20101114140920.E013.A69D9226@jp.fujitsu.com>
	<AANLkTim59Qx6TsvXnTBL5Lg6JorbGaqx3KsdBDWO04X9@mail.gmail.com>
	<1289810825.2109.469.camel@laptop>
	<AANLkTikibS1fDuk67RHk4SU14pJ9nPdodWba1T3Z_pWE@mail.gmail.com>
	<4CE14848.2060805@redhat.com>
	<AANLkTi=6RtPDnZZa=jrcciB1zHQMiB3LnouBw3G2OyaK@mail.gmail.com>
	<4CE40129.9060103@redhat.com>
	<AANLkTin2fXGOAdGNegDhijjo_kV7nOBJP_hagjgoYdtX@mail.gmail.com>
	<4CE49C8B.2050005@redhat.com>
Date: Thu, 18 Nov 2010 12:46:44 +0900
Message-ID: <AANLkTi=4DbR8bX3VX=Wymo6Tk7yyR_=BEmJx+WY_0iRs@mail.gmail.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Gamari <bgamari.foss@gmail.com>, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 12:24 PM, Rik van Riel <riel@redhat.com> wrote:
> On 11/17/2010 09:47 PM, Minchan Kim wrote:
>>
>> On Thu, Nov 18, 2010 at 1:22 AM, Rik van Riel<riel@redhat.com> =A0wrote:
>>>
>>> On 11/17/2010 05:16 AM, Minchan Kim wrote:
>>>
>>>> Absolutely. But how about rsync's two touch?
>>>> It can evict working set.
>>>>
>>>> I need the time for investigation.
>>>> Thanks for the comment.
>>>
>>> Maybe we could exempt MADV_SEQUENTIAL and FADV_SEQUENTIAL
>>> touches from promoting the page to the active list?
>>>
>>
>> The problem is non-mapped file page.
>> non-mapped file page promotion happens by only mark_page_accessed.
>> But it doesn't enough information to prevent promotion(ex, vma or file)
>
> I believe we have enough information in filemap.c and can just
> pass that as a parameter to mark_page_accessed.

FADV_SEQUENTIAL is per file/vma semantic and It is used by many place.
I think changing all those places isn't simple and I don't want to add
new structure to propagate the information to mark_page_accessed.

>
>> Here is another idea.
>> Current problem is following as.
>> User can use fadivse with FADV_DONTNEED.
>> But problem is that it can't affect when it meet dirty pages.
>> So user have to sync dirty page before calling fadvise with FADV_DONTNEE=
D.
>> It would lose performance.
>>
>> Let's add some semantic of FADV_DONTNEED.
>> It invalidates only pages which are not dirty.
>> If it meets dirty page, let's move the page into inactive's tail or head=
