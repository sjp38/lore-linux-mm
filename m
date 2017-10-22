Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 20B2B6B0038
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 04:24:20 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id q126so17514502ywq.6
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 01:24:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p8sor2152366ybe.40.2017.10.22.01.24.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Oct 2017 01:24:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b530521e-5215-f735-444a-13f722d90e40@alibaba-inc.com>
References: <1508448056-21779-1-git-send-email-yang.s@alibaba-inc.com>
 <CAOQ4uxhPhXrMLu18TGKDA=ezUVHara95qJQ+BTCio8BHm-u6NA@mail.gmail.com> <b530521e-5215-f735-444a-13f722d90e40@alibaba-inc.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Sun, 22 Oct 2017 11:24:17 +0300
Message-ID: <CAOQ4uxhFOoSknnG-0Jyv+=iCDjVNnAg6SiO-msxw4tORkVKJGQ@mail.gmail.com>
Subject: Re: [RFC PATCH] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: multipart/mixed; boundary="f403045db94ea1ff36055c1e6ee5"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

--f403045db94ea1ff36055c1e6ee5
Content-Type: text/plain; charset="UTF-8"

On Sat, Oct 21, 2017 at 12:07 AM, Yang Shi <yang.s@alibaba-inc.com> wrote:
>
>
> On 10/19/17 8:14 PM, Amir Goldstein wrote:
>>
>> On Fri, Oct 20, 2017 at 12:20 AM, Yang Shi <yang.s@alibaba-inc.com> wrote:
>>>
>>> We observed some misbehaved user applications might consume significant
>>> amount of fsnotify slabs silently. It'd better to account those slabs in
>>> kmemcg so that we can get heads up before misbehaved applications use too
>>> much memory silently.
>>
>>
>> In what way do they misbehave? create a lot of marks? create a lot of
>> events?
>> Not reading events in their queue?
>
>
> It looks both a lot marks and events. I'm not sure if it is the latter case.
> If I knew more about the details of the behavior, I would elaborated more in
> the commit log.

If you are not sure, do not refer to user application as "misbehaved".
Is updatedb(8) a misbehaved application because it produces a lot of access
events?
It would be better if you provide the dry facts of your setup and slab counters
and say that you are missing information to analyse the distribution of slab
usage because of missing kmemcg accounting.


>
>> The latter case is more interesting:
>>
>> Process A is the one that asked to get the events.
>> Process B is the one that is generating the events and queuing them on
>> the queue that is owned by process A, who is also to blame if the queue
>> is not being read.
>
>
> I agree it is not fair to account the memory to the generator. But, afaik,
> accounting non-current memcg is not how memcg is designed and works. Please
> see the below for some details.
>
>>
>> So why should process B be held accountable for memory pressure
>> caused by, say, an FAN_UNLIMITED_QUEUE that process A created and
>> doesn't read from.
>>
>> Is it possible to get an explicit reference to the memcg's  events cache
>> at fsnotify_group creation time, store it in the group struct and then
>> allocate
>> events from the event cache associated with the group (the listener)
>> rather
>> than the cache associated with the task generating the event?
>
>
> I don't think current memcg design can do this. Because kmem accounting
> happens at allocation (when calling kmem_cache_alloc) stage, and get the
> associated memcg from current task, so basically who does the allocation who
> get it accounted. If the producer is in the different memcg of consumer, it
> should be just accounted to the producer memcg, although the problem might
> be caused by the producer.
>
> However, afaik, both producer and consumer are typically in the same memcg.
> So, this might be not a big issue. But, I do admit such unfair accounting
> may happen.
>

That is a reasonable argument, but please make a comment on that fact in
commit message and above creation of events cache, so that it is clear that
event slab accounting is mostly heuristic.

But I think there is another problem, not introduced by your change, but could
be amplified because of it - when a non-permission event allocation fails, the
event is silently dropped, AFAICT, with no indication to listener.
That seems like a bug to me, because there is a perfectly safe way to deal with
event allocation failure - queue the overflow event.

I am not going to be the one to determine if fixing this alleged bug is a
prerequisite for merging your patch, but I think enforcing memory limits on
event allocation could amplify that bug, so it should be fixed.

The upside is that with both your accounting fix and ENOMEM = overlflow
fix, it going to be easy to write a test that verifies both of them:
- Run a listener in memcg with limited kmem and unlimited (or very
large) event queue
- Produce events inside memcg without listener reading them
- Read event and expect an OVERFLOW event

This is a simple variant of LTP tests inotify05 and fanotify05.

I realize that is user application behavior change and that documentation
implies that an OVERFLOW event is not expected when using
FAN_UNLIMITED_QUEUE, but IMO no one will come shouting
if we stop silently dropping events, so it is better to fix this and update
documentation.

Attached a compile-tested patch to implement overflow on ENOMEM
Hope this helps to test your patch and then we can merge both, accompanied
with LTP tests for inotify and fanotify.

Amir.

--f403045db94ea1ff36055c1e6ee5
Content-Type: text/x-patch; charset="US-ASCII";
	name="0001-fsnotify-queue-an-overflow-event-on-failure-to-alloc.patch"
Content-Disposition: attachment;
	filename="0001-fsnotify-queue-an-overflow-event-on-failure-to-alloc.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j92hel2i0

RnJvbSAxMTJlY2Q1NDA0NWYxNGFmZjJjNDI2MjJmYWJiNGZmYWI5ZjBkOGZmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBbWlyIEdvbGRzdGVpbiA8YW1pcjczaWxAZ21haWwuY29tPgpE
YXRlOiBTdW4sIDIyIE9jdCAyMDE3IDExOjEzOjEwICswMzAwClN1YmplY3Q6IFtQQVRDSF0gZnNu
b3RpZnk6IHF1ZXVlIGFuIG92ZXJmbG93IGV2ZW50IG9uIGZhaWx1cmUgdG8gYWxsb2NhdGUKIGV2
ZW50CgpJbiBsb3cgbWVtb3J5IHNpdHVhdGlvbnMsIG5vbiBwZXJtaXNzaW9ucyBldmVudHMgYXJl
IHNpbGVudGx5IGRyb3BwZWQuCkl0IGlzIGJldHRlciB0byBxdWV1ZSBhbiBPVkVSRkxPVyBldmVu
dCBpbiB0aGF0IGNhc2UgdG8gbGV0IHRoZSBsaXN0ZW5lcgprbm93IGFib3V0IHRoZSBsb3N0IGV2
ZW50LgoKV2l0aCB0aGlzIGNoYW5nZSwgYW4gYXBwbGljYXRpb24gY2FuIG5vdyBnZXQgYW4gRkFO
X1FfT1ZFUkZMT1cgZXZlbnQsCmV2ZW4gaWYgaXQgdXNlZCBmbGFnIEZBTl9VTkxJTUlURURfUVVF
VUUgb24gZmFub3RpZnlfaW5pdCgpLgoKU2lnbmVkLW9mZi1ieTogQW1pciBHb2xkc3RlaW4gPGFt
aXI3M2lsQGdtYWlsLmNvbT4KLS0tCiBmcy9ub3RpZnkvZmFub3RpZnkvZmFub3RpZnkuYyAgICAg
ICAgfCAxMCArKysrKysrKy0tCiBmcy9ub3RpZnkvaW5vdGlmeS9pbm90aWZ5X2Zzbm90aWZ5LmMg
fCAgOCArKysrKystLQogZnMvbm90aWZ5L25vdGlmaWNhdGlvbi5jICAgICAgICAgICAgIHwgIDMg
KystCiAzIGZpbGVzIGNoYW5nZWQsIDE2IGluc2VydGlvbnMoKyksIDUgZGVsZXRpb25zKC0pCgpk
aWZmIC0tZ2l0IGEvZnMvbm90aWZ5L2Zhbm90aWZ5L2Zhbm90aWZ5LmMgYi9mcy9ub3RpZnkvZmFu
b3RpZnkvZmFub3RpZnkuYwppbmRleCAyZmE5OWFlYWEwOTUuLjQxMmEzMjgzOGY1OCAxMDA2NDQK
LS0tIGEvZnMvbm90aWZ5L2Zhbm90aWZ5L2Zhbm90aWZ5LmMKKysrIGIvZnMvbm90aWZ5L2Zhbm90
aWZ5L2Zhbm90aWZ5LmMKQEAgLTIxMiw4ICsyMTIsMTQgQEAgc3RhdGljIGludCBmYW5vdGlmeV9o
YW5kbGVfZXZlbnQoc3RydWN0IGZzbm90aWZ5X2dyb3VwICpncm91cCwKIAkJIG1hc2spOwogCiAJ
ZXZlbnQgPSBmYW5vdGlmeV9hbGxvY19ldmVudChpbm9kZSwgbWFzaywgZGF0YSk7Ci0JaWYgKHVu
bGlrZWx5KCFldmVudCkpCi0JCXJldHVybiAtRU5PTUVNOworCWlmICh1bmxpa2VseSghZXZlbnQp
KSB7CisJCWlmIChtYXNrICYgRkFOX0FMTF9QRVJNX0VWRU5UUykKKwkJCXJldHVybiAtRU5PTUVN
OworCisJCS8qIFF1ZXVlIGFuIG92ZXJmbG93IGV2ZW50IG9uIGZhaWx1cmUgdG8gYWxsb2NhdGUg
ZXZlbnQgKi8KKwkJZnNub3RpZnlfYWRkX2V2ZW50KGdyb3VwLCBncm91cC0+b3ZlcmZsb3dfZXZl
bnQsIE5VTEwpOworCQlyZXR1cm4gMDsKKwl9CiAKIAlmc25fZXZlbnQgPSAmZXZlbnQtPmZzZTsK
IAlyZXQgPSBmc25vdGlmeV9hZGRfZXZlbnQoZ3JvdXAsIGZzbl9ldmVudCwgZmFub3RpZnlfbWVy
Z2UpOwpkaWZmIC0tZ2l0IGEvZnMvbm90aWZ5L2lub3RpZnkvaW5vdGlmeV9mc25vdGlmeS5jIGIv
ZnMvbm90aWZ5L2lub3RpZnkvaW5vdGlmeV9mc25vdGlmeS5jCmluZGV4IDhiNzMzMzI3MzViYS4u
ZDE4MzdkYTJlZjE1IDEwMDY0NAotLS0gYS9mcy9ub3RpZnkvaW5vdGlmeS9pbm90aWZ5X2Zzbm90
aWZ5LmMKKysrIGIvZnMvbm90aWZ5L2lub3RpZnkvaW5vdGlmeV9mc25vdGlmeS5jCkBAIC05OSw4
ICs5OSwxMSBAQCBpbnQgaW5vdGlmeV9oYW5kbGVfZXZlbnQoc3RydWN0IGZzbm90aWZ5X2dyb3Vw
ICpncm91cCwKIAkJCSAgICAgIGZzbl9tYXJrKTsKIAogCWV2ZW50ID0ga21hbGxvYyhhbGxvY19s
ZW4sIEdGUF9LRVJORUwpOwotCWlmICh1bmxpa2VseSghZXZlbnQpKQotCQlyZXR1cm4gLUVOT01F
TTsKKwlpZiAodW5saWtlbHkoIWV2ZW50KSkgeworCQkvKiBRdWV1ZSBhbiBvdmVyZmxvdyBldmVu
dCBvbiBmYWlsdXJlIHRvIGFsbG9jYXRlIGV2ZW50ICovCisJCWZzbm90aWZ5X2FkZF9ldmVudChn
cm91cCwgZ3JvdXAtPm92ZXJmbG93X2V2ZW50LCBOVUxMKTsKKwkJZ290byBvbmVzaG90OworCX0K
IAogCWZzbl9ldmVudCA9ICZldmVudC0+ZnNlOwogCWZzbm90aWZ5X2luaXRfZXZlbnQoZnNuX2V2
ZW50LCBpbm9kZSwgbWFzayk7CkBAIC0xMTYsNiArMTE5LDcgQEAgaW50IGlub3RpZnlfaGFuZGxl
X2V2ZW50KHN0cnVjdCBmc25vdGlmeV9ncm91cCAqZ3JvdXAsCiAJCWZzbm90aWZ5X2Rlc3Ryb3lf
ZXZlbnQoZ3JvdXAsIGZzbl9ldmVudCk7CiAJfQogCitvbmVzaG90OgogCWlmIChpbm9kZV9tYXJr
LT5tYXNrICYgSU5fT05FU0hPVCkKIAkJZnNub3RpZnlfZGVzdHJveV9tYXJrKGlub2RlX21hcmss
IGdyb3VwKTsKIApkaWZmIC0tZ2l0IGEvZnMvbm90aWZ5L25vdGlmaWNhdGlvbi5jIGIvZnMvbm90
aWZ5L25vdGlmaWNhdGlvbi5jCmluZGV4IDY2Zjg1YzY1MWM1Mi4uNWFiZDY5OTc2YTQ3IDEwMDY0
NAotLS0gYS9mcy9ub3RpZnkvbm90aWZpY2F0aW9uLmMKKysrIGIvZnMvbm90aWZ5L25vdGlmaWNh
dGlvbi5jCkBAIC0xMTEsNyArMTExLDggQEAgaW50IGZzbm90aWZ5X2FkZF9ldmVudChzdHJ1Y3Qg
ZnNub3RpZnlfZ3JvdXAgKmdyb3VwLAogCQlyZXR1cm4gMjsKIAl9CiAKLQlpZiAoZ3JvdXAtPnFf
bGVuID49IGdyb3VwLT5tYXhfZXZlbnRzKSB7CisJaWYgKGdyb3VwLT5xX2xlbiA+PSBncm91cC0+
bWF4X2V2ZW50cyB8fAorCSAgICBldmVudCA9PSBncm91cC0+b3ZlcmZsb3dfZXZlbnQpIHsKIAkJ
cmV0ID0gMjsKIAkJLyogUXVldWUgb3ZlcmZsb3cgZXZlbnQgb25seSBpZiBpdCBpc24ndCBhbHJl
YWR5IHF1ZXVlZCAqLwogCQlpZiAoIWxpc3RfZW1wdHkoJmdyb3VwLT5vdmVyZmxvd19ldmVudC0+
bGlzdCkpIHsKLS0gCjIuNy40Cgo=
--f403045db94ea1ff36055c1e6ee5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
