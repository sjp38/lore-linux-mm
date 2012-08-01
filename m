Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 66EF86B004D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 01:15:34 -0400 (EDT)
Received: by obhx4 with SMTP id x4so14534394obh.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 22:15:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1207301425410.28838@router.home>
References: <1343411703-2720-1-git-send-email-js1304@gmail.com>
 <1343411703-2720-4-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1207271550190.25434@router.home>
 <CAAmzW4MdiJOaZW_b+fz1uYyj0asTCveN=24st4xKymKEvkzdgQ@mail.gmail.com> <alpine.DEB.2.00.1207301425410.28838@router.home>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Wed, 1 Aug 2012 07:15:13 +0200
Message-ID: <CAHO5Pa0wwSi3VH1ytLZsEJs99i_=5qN5ax=8y=uz1jbG+P03sw@mail.gmail.com>
Subject: Re: [RESEND PATCH 4/4 v3] mm: fix possible incorrect return value of
 move_pages() syscall
Content-Type: multipart/mixed; boundary=e89a8f503194656fdb04c62d6269
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: JoonSoo Kim <js1304@gmail.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Brice Goglin <brice@myri.com>, Minchan Kim <minchan@kernel.org>

--e89a8f503194656fdb04c62d6269
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Jul 30, 2012 at 9:29 PM, Christoph Lameter <cl@linux.com> wrote:
> On Sat, 28 Jul 2012, JoonSoo Kim wrote:
>
>> 2012/7/28 Christoph Lameter <cl@linux.com>:
>> > On Sat, 28 Jul 2012, Joonsoo Kim wrote:
>> >
>> >> move_pages() syscall may return success in case that
>> >> do_move_page_to_node_array return positive value which means migration failed.
>> >
>> > Nope. It only means that the migration for some pages has failed. This may
>> > still be considered successful for the app if it moves 10000 pages and one
>> > failed.
>> >
>> > This patch would break the move_pages() syscall because an error code
>> > return from do_move_pages_to_node_array() will cause the status byte for
>> > each page move to not be updated anymore. Application will not be able to
>> > tell anymore which pages were successfully moved and which are not.
>>
>> In case of returning non-zero, valid status is not required according
>> to man page.
>
> Cannot find a statement like that in the man page. The return code
> description is incorrect. It should that that is returns the number of
> pages not moved otherwise an error code (Michael please fix the manpage).

Hi Christoph,

Is the patch below acceptable? (I've attached the complete page as well.)

See you in San Diego (?),

Michael

--- a/man2/migrate_pages.2
+++ b/man2/migrate_pages.2
@@ -29,7 +29,7 @@ migrate_pages \- move all pages in a process to
another set of nodes
 Link with \fI\-lnuma\fP.
 .SH DESCRIPTION
 .BR migrate_pages ()
-moves all pages of the process
+attempts to move all pages of the process
 .I pid
 that are in memory nodes
 .I old_nodes
@@ -87,7 +87,8 @@ privilege.
 .SH "RETURN VALUE"
 On success
 .BR migrate_pages ()
-returns zero.
+returns the number of pages that cold not be moved
+(i.e., a return of zero means that all pages were successfully moved).
 On error, it returns \-1, and sets
 .I errno
 to indicate the error.

-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/

--e89a8f503194656fdb04c62d6269
Content-Type: application/octet-stream; name="migrate_pages.2"
Content-Disposition: attachment; filename="migrate_pages.2"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h5byno0n0

LlwiIEhleSBFbWFjcyEgVGhpcyBmaWxlIGlzIC0qLSBucm9mZiAtKi0gc291cmNlLgouXCIKLlwi
IENvcHlyaWdodCAyMDA5IEludGVsIENvcnBvcmF0aW9uCi5cIiAgICAgICAgICAgICAgICBBdXRo
b3I6IEFuZGkgS2xlZW4KLlwiIEJhc2VkIG9uIHRoZSBtb3ZlX3BhZ2VzIG1hbnBhZ2Ugd2hpY2gg
d2FzCi5cIiBUaGlzIG1hbnBhZ2UgaXMgQ29weXJpZ2h0IChDKSAyMDA2IFNpbGljb24gR3JhcGhp
Y3MsIEluYy4KLlwiICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIENocmlzdG9waCBMYW1l
dGVyCi5cIgouXCIgUGVybWlzc2lvbiBpcyBncmFudGVkIHRvIG1ha2UgYW5kIGRpc3RyaWJ1dGUg
dmVyYmF0aW0gY29waWVzIG9mIHRoaXMKLlwiIG1hbnVhbCBwcm92aWRlZCB0aGUgY29weXJpZ2h0
IG5vdGljZSBhbmQgdGhpcyBwZXJtaXNzaW9uIG5vdGljZSBhcmUKLlwiIHByZXNlcnZlZCBvbiBh
bGwgY29waWVzLgouXCIKLlwiIFBlcm1pc3Npb24gaXMgZ3JhbnRlZCB0byBjb3B5IGFuZCBkaXN0
cmlidXRlIG1vZGlmaWVkIHZlcnNpb25zIG9mIHRoaXMKLlwiIG1hbnVhbCB1bmRlciB0aGUgY29u
ZGl0aW9ucyBmb3IgdmVyYmF0aW0gY29weWluZywgcHJvdmlkZWQgdGhhdCB0aGUKLlwiIGVudGly
ZSByZXN1bHRpbmcgZGVyaXZlZCB3b3JrIGlzIGRpc3RyaWJ1dGVkIHVuZGVyIHRoZSB0ZXJtcyBv
ZiBhCi5cIiBwZXJtaXNzaW9uIG5vdGljZSBpZGVudGljYWwgdG8gdGhpcyBvbmUuCi5USCBNSUdS
QVRFX1BBR0VTIDIgMjAxMi0wOC0wMSAiTGludXgiICJMaW51eCBQcm9ncmFtbWVyJ3MgTWFudWFs
IgouU0ggTkFNRQptaWdyYXRlX3BhZ2VzIFwtIG1vdmUgYWxsIHBhZ2VzIGluIGEgcHJvY2VzcyB0
byBhbm90aGVyIHNldCBvZiBub2RlcwouU0ggU1lOT1BTSVMKLm5mCi5CICNpbmNsdWRlIDxudW1h
aWYuaD4KLnNwCi5CSSAibG9uZyBtaWdyYXRlX3BhZ2VzKGludCAiIHBpZCAiLCB1bnNpZ25lZCBs
b25nICIgbWF4bm9kZSwKLkJJICIgICAgICAgICAgICAgICAgICAgY29uc3QgdW5zaWduZWQgbG9u
ZyAqIiBvbGRfbm9kZXMsCi5CSSAiICAgICAgICAgICAgICAgICAgIGNvbnN0IHVuc2lnbmVkIGxv
bmcgKiIgbmV3X25vZGVzKTsKLmZpCi5zcApMaW5rIHdpdGggXGZJXC1sbnVtYVxmUC4KLlNIIERF
U0NSSVBUSU9OCi5CUiBtaWdyYXRlX3BhZ2VzICgpCmF0dGVtcHRzIHRvIG1vdmUgYWxsIHBhZ2Vz
IG9mIHRoZSBwcm9jZXNzCi5JIHBpZAp0aGF0IGFyZSBpbiBtZW1vcnkgbm9kZXMKLkkgb2xkX25v
ZGVzCnRvIHRoZSBtZW1vcnkgbm9kZXMgaW4KLklSIG5ld19ub2RlcyAuClBhZ2VzIG5vdCBsb2Nh
dGVkIGluIGFueSBub2RlIGluCi5JIG9sZF9ub2Rlcwp3aWxsIG5vdCBiZSBtaWdyYXRlZC4KQXMg
ZmFyIGFzIHBvc3NpYmxlLAp0aGUga2VybmVsIG1haW50YWlucyB0aGUgcmVsYXRpdmUgdG9wb2xv
Z3kgcmVsYXRpb25zaGlwIGluc2lkZQouSSBvbGRfbm9kZXMKZHVyaW5nIHRoZSBtaWdyYXRpb24g
dG8KLklSIG5ld19ub2RlcyAuCgpUaGUKLkkgb2xkX25vZGVzCmFuZAouSSBuZXdfbm9kZXMKYXJn
dW1lbnRzIGFyZSBwb2ludGVycyB0byBiaXQgbWFza3Mgb2Ygbm9kZSBudW1iZXJzLCB3aXRoIHVw
IHRvCi5JIG1heG5vZGUKYml0cyBpbiBlYWNoIG1hc2suClRoZXNlIG1hc2tzIGFyZSBtYWludGFp
bmVkIGFzIGFycmF5cyBvZiB1bnNpZ25lZAouSSBsb25nCmludGVnZXJzIChpbiB0aGUgbGFzdAou
SSBsb25nCmludGVnZXIsIHRoZSBiaXRzIGJleW9uZCB0aG9zZSBzcGVjaWZpZWQgYnkKLkkgbWF4
bm9kZQphcmUgaWdub3JlZCkuClRoZQouSSBtYXhub2RlCmFyZ3VtZW50IGlzIHRoZSBtYXhpbXVt
IG5vZGUgbnVtYmVyIGluIHRoZSBiaXQgbWFzayBwbHVzIG9uZSAodGhpcyBpcyB0aGUgc2FtZQph
cyBpbgouQlIgbWJpbmQgKDIpLApidXQgZGlmZmVyZW50IGZyb20KLkJSIHNlbGVjdCAoMikpLgoK
VGhlCi5JIHBpZAphcmd1bWVudCBpcyB0aGUgSUQgb2YgdGhlIHByb2Nlc3Mgd2hvc2UgcGFnZXMg
YXJlIHRvIGJlIG1vdmVkLgpUbyBtb3ZlIHBhZ2VzIGluIGFub3RoZXIgcHJvY2VzcywKdGhlIGNh
bGxlciBtdXN0IGJlIHByaXZpbGVnZWQKLlJCICggQ0FQX1NZU19OSUNFICkKb3IgdGhlIHJlYWwg
b3IgZWZmZWN0aXZlIHVzZXIgSUQgb2YgdGhlIGNhbGxpbmcgcHJvY2VzcyBtdXN0IG1hdGNoIHRo
ZQpyZWFsIG9yIHNhdmVkLXNldCB1c2VyIElEIG9mIHRoZSB0YXJnZXQgcHJvY2Vzcy4KSWYKLkkg
cGlkCmlzIDAsIHRoZW4KLkJSIG1pZ3JhdGVfcGFnZXMgKCkKbW92ZXMgcGFnZXMgb2YgdGhlIGNh
bGxpbmcgcHJvY2Vzcy4KClBhZ2VzIHNoYXJlZCB3aXRoIGFub3RoZXIgcHJvY2VzcyB3aWxsIG9u
bHkgYmUgbW92ZWQgaWYgdGhlIGluaXRpYXRpbmcKcHJvY2VzcyBoYXMgdGhlCi5CIENBUF9TWVNf
TklDRQpwcml2aWxlZ2UuCi5TSCAiUkVUVVJOIFZBTFVFIgpPbiBzdWNjZXNzCi5CUiBtaWdyYXRl
X3BhZ2VzICgpCnJldHVybnMgdGhlIG51bWJlciBvZiBwYWdlcyB0aGF0IGNvbGQgbm90IGJlIG1v
dmVkCihpLmUuLCBhIHJldHVybiBvZiB6ZXJvIG1lYW5zIHRoYXQgYWxsIHBhZ2VzIHdlcmUgc3Vj
Y2Vzc2Z1bGx5IG1vdmVkKS4KT24gZXJyb3IsIGl0IHJldHVybnMgXC0xLCBhbmQgc2V0cwouSSBl
cnJubwp0byBpbmRpY2F0ZSB0aGUgZXJyb3IuCi5TSCBFUlJPUlMKLlRQCi5CIEVQRVJNCkluc3Vm
ZmljaWVudCBwcml2aWxlZ2UKLlJCICggQ0FQX1NZU19OSUNFICkKdG8gbW92ZSBwYWdlcyBvZiB0
aGUgcHJvY2VzcyBzcGVjaWZpZWQgYnkKLklSIHBpZCAsCm9yIGluc3VmZmljaWVudCBwcml2aWxl
Z2UKLlJCICggQ0FQX1NZU19OSUNFICkKdG8gYWNjZXNzIHRoZSBzcGVjaWZpZWQgdGFyZ2V0IG5v
ZGVzLgouVFAKLkIgRVNSQ0gKTm8gcHJvY2VzcyBtYXRjaGluZwouSSBwaWQKY291bGQgYmUgZm91
bmQuCi5cIiBGSVhNRSBUaGVyZSBhcmUgb3RoZXIgZXJyb3JzCi5TSCBWRVJTSU9OUwpUaGUKLkJS
IG1pZ3JhdGVfcGFnZXMgKCkKc3lzdGVtIGNhbGwgZmlyc3QgYXBwZWFyZWQgb24gTGludXggaW4g
dmVyc2lvbiAyLjYuMTYuCi5TSCBDT05GT1JNSU5HIFRPClRoaXMgc3lzdGVtIGNhbGwgaXMgTGlu
dXgtc3BlY2lmaWMuCi5TSCAiTk9URVMiCkZvciBpbmZvcm1hdGlvbiBvbiBsaWJyYXJ5IHN1cHBv
cnQsIHNlZQouQlIgbnVtYSAoNykuCgpVc2UKLkJSIGdldF9tZW1wb2xpY3kgKDIpCndpdGggdGhl
Ci5CIE1QT0xfRl9NRU1TX0FMTE9XRUQKZmxhZyB0byBvYnRhaW4gdGhlIHNldCBvZiBub2RlcyB0
aGF0IGFyZSBhbGxvd2VkIGJ5CnRoZSBjYWxsaW5nIHByb2Nlc3MncyBjcHVzZXQuCk5vdGUgdGhh
dCB0aGlzIGluZm9ybWF0aW9uIGlzIHN1YmplY3QgdG8gY2hhbmdlIGF0IGFueQp0aW1lIGJ5IG1h
bnVhbCBvciBhdXRvbWF0aWMgcmVjb25maWd1cmF0aW9uIG9mIHRoZSBjcHVzZXQuCgpVc2Ugb2YK
LkJSIG1pZ3JhdGVfcGFnZXMgKCkKbWF5IHJlc3VsdCBpbiBwYWdlcyB3aG9zZSBsb2NhdGlvbgoo
bm9kZSkgdmlvbGF0ZXMgdGhlIG1lbW9yeSBwb2xpY3kgZXN0YWJsaXNoZWQgZm9yIHRoZQpzcGVj
aWZpZWQgYWRkcmVzc2VzIChzZWUKLkJSIG1iaW5kICgyKSkKYW5kL29yIHRoZSBzcGVjaWZpZWQg
cHJvY2VzcyAoc2VlCi5CUiBzZXRfbWVtcG9saWN5ICgyKSkuClRoYXQgaXMsIG1lbW9yeSBwb2xp
Y3kgZG9lcyBub3QgY29uc3RyYWluIHRoZSBkZXN0aW5hdGlvbgpub2RlcyB1c2VkIGJ5Ci5CUiBt
aWdyYXRlX3BhZ2VzICgpLgoKVGhlCi5JIDxudW1haWYuaD4KaGVhZGVyIGlzIG5vdCBpbmNsdWRl
ZCB3aXRoIGdsaWJjLCBidXQgcmVxdWlyZXMgaW5zdGFsbGluZwouSSBsaWJudW1hLWRldmVsCm9y
IGEgc2ltaWxhciBwYWNrYWdlLgouU0ggIlNFRSBBTFNPIgouQlIgZ2V0X21lbXBvbGljeSAoMiks
Ci5CUiBtYmluZCAoMiksCi5CUiBzZXRfbWVtcG9saWN5ICgyKSwKLkJSIG51bWEgKDMpLAouQlIg
bnVtYV9tYXBzICg1KSwKLkJSIGNwdXNldCAoNyksCi5CUiBudW1hICg3KSwKLkJSIG1pZ3JhdGVw
YWdlcyAoOCksCi5CUiBudW1hX3N0YXQgKDgpOwouYnIKdGhlIGtlcm5lbCBzb3VyY2UgZmlsZQou
SVIgRG9jdW1lbnRhdGlvbi92bS9wYWdlX21pZ3JhdGlvbiAuCg==
--e89a8f503194656fdb04c62d6269--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
