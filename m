Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 59A176B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 19:57:40 -0500 (EST)
Message-ID: <4B22E9F6.4000100@bx.jp.nec.com>
Date: Fri, 11 Dec 2009 19:55:18 -0500
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: [RFC PATCH -tip 0/1][RESEND] tracepoints: pagecache tracepoints proposal
References: <4B22E64E.1@bx.jp.nec.com>
In-Reply-To: <4B22E64E.1@bx.jp.nec.com>
Content-Type: multipart/mixed;
 boundary="------------070909050907020509060005"
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Keiichi KII <k-keiichi@bx.jp.nec.com>, lwoodman@redhat.com, linux-mm@kvack.org, mingo@elte.hu, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070909050907020509060005
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

Hello,

Sorry for misspell linux-mm ML.
So, I send the patch again.

I would propose several tracepoints for tracing pagecache behaviors.
By using the tracepoints, we can monitor pagecache usage with high resolution.

-----------------------------------------------------------------------------
# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
      postmaster-7293  [002] 104039.093744: find_get_page: s_dev=8:2 i_ino=19672
42 offset=22302 page_found
      postmaster-7293  [000] 104047.138110: add_to_page_cache: s_dev=8:2 i_ino=1
967242 offset=5672
      postmaster-7293  [000] 104072.590885: remove_from_page_cache: s_dev=8:2 i_
ino=5016146 offset=1
-----------------------------------------------------------------------------

We can now know system-wide pagecache usage by /proc/meminfo.
But we have no method to get higher resolution information like per file or
per process usage than system-wide one.
A process may share some pagecache or add a pagecache to the memory or
remove a pagecache from the memory.
If a pagecache miss hit ratio rises, maybe it leads to extra I/O and
affects system performance.

So, by using the tracepoints we can get the following information.
 1. how many pagecaches each process has per each file
 2. how many pages are cached per each file
 3. how many pagecaches each process shares
 4. how often each process adds/removes pagecache
 5. how long a pagecache stays in the memory
 6. pagecache hit rate per file

Especially, the monitoring pagecache usage per each file would help us tune
some application like database.
I attach a sample script for counting file-by-file pagecache usage per process.
The scripts processes raw data from <debugfs>/tracing/trace to get
human-readable output.

You can run it as:
  # echo 1 > <debugfs>/tracing/events/filemap
  # cat <debugfs>/tracing/trace | python trace-pagecache-postprocess.py

The script implements counting 1, 2 and 3 information in the above.

o script output format
[file list]
  < pagecache usage on a file basis >
  ...
[process list]
  process: < pagecache usage of this process >
    dev: < pagecache usage of above process on this file >
    ...
  ...

For example:

The below output is pagecache usage when pgbench(benchmark tests on PostgreSQL)
runs.
An inode 1967121 is a part of file(75M) for PostgreSQL database.
An inode 5019039 is a part of exec file(2.9M) for PostgreSQL,
"/usr/bin/postgres".

- if "added"(L8) > "cached"(L2) then
    It means repeating add/remove pagecache many times.
  => Bad case for pagecache usage

- if "cached"(L3) >= "added"(L9)) && "cached"(L6) > 0 then
    It means no unnecessary I/O operations.
  => Good case for pagecache usage.

(the "L2" means that second line in the output, "2:   dev:8:2, ...".)

-----------------------------------------------------------------------------
 1:  [file list]
 2:    dev:8:2, inode:1967121, cached: 13M
 3:    dev:8:2, inode:5019039, cached: 1M
 4:  [process list]
 5:    process: kswapd0-369 (cached:0K, added:0K, removed:0K, indirect removed:10M)
 6:      dev:8:2, inode:1967121, cached:0K, added:0K, removed:0K, indirect removed:10M
 7:    process: postmaster-5025 (cached:23M, added:26M, removed:616K, indirect removed:176K)
 8:      dev:8:2, inode:1967121, cached:22M, added:26M, removed:616K, indirect removed:0K
 9:      dev:8:2, inode:5019039, cached:1M, added:64K, removed:0K, indirect removed:176K
10:    process: dd-5028 (cached:0K, added:0K, removed:0K, indirect removed:1M)
11:      dev:8:2, inode:1967121, cached:0K, added:0K, removed:0K, indirect removed:848K
12:      dev:8:2, inode:5019039, cached:0K, added:0K, removed:0K, indirect removed:396K
-----------------------------------------------------------------------------

Any comments are welcome.
--
Keiichi Kii <k-keiichi@bx.jp.nec.com>


--------------070909050907020509060005
Content-Type: text/plain;
 name="trace-pagecache-postprocess.py"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="trace-pagecache-postprocess.py"

IyEvdXNyL2Jpbi9lbnYgcHl0aG9uCgppbXBvcnQgc3lzLCByZSwgZ2V0b3B0CgpjbGFzcyBS
ZWNvcmRlcjoKICAgIHJlZ2V4X2RhdGEgPSByZS5jb21waWxlKCJzX2Rldj0oLiopIGlfaW5v
PSguKikgb2Zmc2V0PSguKikiKQogICAgcmVnZXhfZGF0YV9mb3JfZmluZCA9IHJlLmNvbXBp
bGUoInNfZGV2PSguKikgaV9pbm89KC4qKSBvZmZzZXQ9KC4qKSAoLiopIikKCiAgICBkZWYg
X19pbml0X18oc2VsZik6CiAgICAgICAgc2VsZi5fX3Byb2Nlc3NlcyA9IHt9CiAgICAgICAg
c2VsZi5fX2ZpbGVzID0ge30KICAgICAgICBzZWxmLl9fcmVjb3JkcyA9IHt9CiAgICAgICAg
KHNlbGYuX190cHJvY2Vzcywgc2VsZi5fX3RkZXYsIHNlbGYuX190aW5vZGUpID0gKE5vbmUs
IE5vbmUsIE5vbmUpCgogICAgZGVmIGdldF9maWxlcyhzZWxmKToKICAgICAgICByZXR1cm4g
c2VsZi5fX2ZpbGVzLnZhbHVlcygpCgogICAgZGVmIGdldF9wcm9jZXNzZXMoc2VsZik6CiAg
ICAgICAgcmV0dXJuIHNlbGYuX19wcm9jZXNzZXMudmFsdWVzKCkKCiAgICBkZWYgZ2V0X3By
b2Nlc3Moc2VsZiwgbmFtZSk6CiAgICAgICAgaWYgbm90IG5hbWUgaW4gc2VsZi5fX3Byb2Nl
c3NlczoKICAgICAgICAgICAgc2VsZi5fX3Byb2Nlc3Nlc1tuYW1lXSA9IFByb2Nlc3MobmFt
ZSkKICAgICAgICByZXR1cm4gc2VsZi5fX3Byb2Nlc3Nlc1tuYW1lXQoKICAgIGRlZiBzZXRf
dGFyZ2V0KHNlbGYsIHByb2Nlc3MsIGRldiwgaW5vZGUpOgogICAgICAgIChzZWxmLl9fdHBy
b2Nlc3MsIHNlbGYuX190ZGV2LCBzZWxmLl9fdGlub2RlICkgPSAocHJvY2VzcywgZGV2LCBp
bm9kZSkKCiAgICBkZWYgZ2V0X2ZpbGUoc2VsZiwgZGV2LCBpbm9kZSk6CiAgICAgICAga2V5
ID0gKGRldiwgaW5vZGUpCiAgICAgICAgaWYgbm90IGtleSBpbiBzZWxmLl9fZmlsZXM6CiAg
ICAgICAgICAgIHNlbGYuX19maWxlc1trZXldID0gRmlsZShkZXYsIGlub2RlKQogICAgICAg
IHJldHVybiBzZWxmLl9fZmlsZXNba2V5XQoKICAgIGRlZiBnZXRfcmVjb3JkcyhzZWxmKToK
ICAgICAgICByZXR1cm4gc2VsZi5fX3JlY29yZHMKCiAgICBkZWYgZ2V0X3JlY29yZChzZWxm
LCBwcm9jZXNzLCBkZXYsIGlub2RlKToKICAgICAgICBpZiBzZWxmLl9fdHByb2Nlc3MgYW5k
IHNlbGYuX190cHJvY2VzcyAhPSBwcm9jZXNzIG9yIFwKICAgICAgICAgICAgICAgIHNlbGYu
X190ZGV2IGFuZCBzZWxmLl9fdGRldiAhPSBkZXYgb3IgXAogICAgICAgICAgICAgICAgc2Vs
Zi5fX3Rpbm9kZSBhbmQgc2VsZi5fX3Rpbm9kZSAhPSBpbm9kZToKICAgICAgICAgICAgcmV0
dXJuIE5vbmUKICAgICAgICBwID0gc2VsZi5nZXRfcHJvY2Vzcyhwcm9jZXNzKQogICAgICAg
IGYgPSBzZWxmLmdldF9maWxlKGRldiwgaW5vZGUpCiAgICAgICAga2V5ID0gKHAsIGYpCiAg
ICAgICAgaWYgbm90IGtleSBpbiBzZWxmLl9fcmVjb3JkczoKICAgICAgICAgICAgc2VsZi5f
X3JlY29yZHNba2V5XSA9IFJlY29yZChwLCBmKQogICAgICAgIHJldHVybiBzZWxmLl9fcmVj
b3Jkc1trZXldCgogICAgZGVmIHJlY29yZF9maW5kX2dldF9wYWdlKHNlbGYsIHByb2Nlc3Ms
IGRhdGEpOgogICAgICAgIG0gPSBSZWNvcmRlci5yZWdleF9kYXRhX2Zvcl9maW5kLm1hdGNo
KGRhdGEpCiAgICAgICAgaWYgbm90IG06CiAgICAgICAgICAgIHByaW50ICJmaW5kX2dldF9w
YWdlKCkgaWxsZWdhbCBmb3JtYXQ6JXMiICUgZGF0YQogICAgICAgIChkZXYsIGlub2RlLCBp
bmRleCwgZmxhZykgPSBtLmdyb3VwcygpCiAgICAgICAgaWYgZmxhZyA9PSAicGFnZV9mb3Vu
ZCI6CiAgICAgICAgICAgIHIgPSBzZWxmLmdldF9yZWNvcmQocHJvY2VzcywgZGV2LCBpbm9k
ZSkKICAgICAgICAgICAgaWYgciAhPSBOb25lOgogICAgICAgICAgICAgICAgci5hY2Nlc3Nf
dG9fY2FjaGVkX3BhZ2UoaW5kZXgpCiAgICAgICAgICAgICAgICByLmdldF9maWxlKCkuYWRk
X3BhZ2UoaW5kZXgpCgogICAgZGVmIHJlY29yZF9hZGRfdG9fcGFnZV9jYWNoZShzZWxmLCBw
cm9jZXNzLCBkYXRhKToKICAgICAgICBtID0gUmVjb3JkZXIucmVnZXhfZGF0YS5tYXRjaChk
YXRhKQogICAgICAgIChkZXYsIGlub2RlLCBpbmRleCkgPSBtLmdyb3VwcygpCiAgICAgICAg
ciA9IHNlbGYuZ2V0X3JlY29yZChwcm9jZXNzLCBkZXYsIGlub2RlKQogICAgICAgIGlmIHIg
IT0gTm9uZToKICAgICAgICAgICAgci5hZGRfdG9fcGFnZV9jYWNoZShpbmRleCkKICAgICAg
ICAgICAgci5nZXRfZmlsZSgpLmFkZF9wYWdlKGluZGV4KQoKICAgIGRlZiByZWNvcmRfcmVt
b3ZlX2Zyb21fcGFnZV9jYWNoZShzZWxmLCBwcm9jZXNzLCBkYXRhKToKICAgICAgICBtID0g
UmVjb3JkZXIucmVnZXhfZGF0YS5tYXRjaChkYXRhKQogICAgICAgIChkZXYsIGlub2RlLCBp
bmRleCkgPSBtLmdyb3VwcygpCiAgICAgICAgciA9IHNlbGYuZ2V0X3JlY29yZChwcm9jZXNz
LCBkZXYsIGlub2RlKQogICAgICAgIGlmIHIgIT0gTm9uZToKICAgICAgICAgICAgci5yZW1v
dmVfZnJvbV9wYWdlX2NhY2hlKGluZGV4KQogICAgICAgICAgICByLmdldF9maWxlKCkucmVt
b3ZlX3BhZ2UoaW5kZXgpCgpjbGFzcyBSZWNvcmQ6CiAgICBkZWYgX19pbml0X18oc2VsZiwg
cHJvY2VzcywgZmlsZSk6CiAgICAgICAgc2VsZi5fX3Byb2Nlc3MgPSBwcm9jZXNzCiAgICAg
ICAgc2VsZi5fX3Byb2Nlc3MuYWRkX3JlY29yZChzZWxmKQogICAgICAgIHNlbGYuX19maWxl
ID0gZmlsZQogICAgICAgIHNlbGYuX19maWxlLmFkZF9yZWNvcmQoc2VsZikKICAgICAgICBz
ZWxmLl9fYWRkZWRfcGFnZV9saXN0ID0gW10KICAgICAgICBzZWxmLl9fcmVtb3ZlZF9wYWdl
X2xpc3QgPSBbXQogICAgICAgIHNlbGYuX19pbmRpcmVjdF9yZW1vdmVkX3BhZ2VfbGlzdCA9
IFtdCiAgICAgICAgc2VsZi5fX2NhY2hlZF9wYWdlX2xpc3QgPSBbXQoKICAgIGRlZiBpc19h
ZGRlZChzZWxmLCBpbmRleCk6CiAgICAgICAgaWYgaW5kZXggaW4gc2VsZi5fX2FkZGVkX3Bh
Z2VfbGlzdCBhbmQgaW5kZXggaW4gc2VsZi5fX2NhY2hlZF9wYWdlX2xpc3Q6CiAgICAgICAg
ICAgIHJldHVybiBUcnVlCiAgICAgICAgZWxzZToKICAgICAgICAgICAgcmV0dXJuIEZhbHNl
CgogICAgZGVmIGdldF9maWxlKHNlbGYpOgogICAgICAgIHJldHVybiBzZWxmLl9fZmlsZQoK
ICAgIGRlZiBjb3VudF9jYWNoZWRfcGFnZShzZWxmKToKICAgICAgICByZXR1cm4gbGVuKHNl
bGYuX19jYWNoZWRfcGFnZV9saXN0KQoKICAgIGRlZiBjb3VudF9hZGRlZF9wYWdlKHNlbGYp
OgogICAgICAgIHJldHVybiBsZW4oc2VsZi5fX2FkZGVkX3BhZ2VfbGlzdCkKCiAgICBkZWYg
Y291bnRfcmVtb3ZlZF9wYWdlKHNlbGYpOgogICAgICAgIHJldHVybiBsZW4oc2VsZi5fX3Jl
bW92ZWRfcGFnZV9saXN0KQoKICAgIGRlZiBjb3VudF9pbmRpcmVjdF9yZW1vdmVkX3BhZ2Uo
c2VsZik6CiAgICAgICAgcmV0dXJuIGxlbihzZWxmLl9faW5kaXJlY3RfcmVtb3ZlZF9wYWdl
X2xpc3QpCgogICAgZGVmIGFjY2Vzc190b19jYWNoZWRfcGFnZShzZWxmLCBpbmRleCk6CiAg
ICAgICAgc2VsZi5fX2NhY2hlZF9wYWdlX2xpc3QuYXBwZW5kKGluZGV4KQoKICAgIGRlZiBh
ZGRfdG9fcGFnZV9jYWNoZShzZWxmLCBpbmRleCk6CiAgICAgICAgc2VsZi5fX2FkZGVkX3Bh
Z2VfbGlzdC5hcHBlbmQoaW5kZXgpCgogICAgZGVmIHJlbW92ZV9mcm9tX3BhZ2VfY2FjaGUo
c2VsZiwgaW5kZXgpOgogICAgICAgIGlmIHNlbGYuaXNfYWRkZWQoaW5kZXgpOgogICAgICAg
ICAgICBzZWxmLl9fcmVtb3ZlZF9wYWdlX2xpc3QuYXBwZW5kKGluZGV4KQogICAgICAgICAg
ICBzZWxmLl9fY2FjaGVkX3BhZ2VfbGlzdC5yZW1vdmUoaW5kZXgpCiAgICAgICAgZWxzZToK
ICAgICAgICAgICAgc2VsZi5fX2luZGlyZWN0X3JlbW92ZWRfcGFnZV9saXN0LmFwcGVuZChp
bmRleCkKCiAgICBkZWYgX19zdHJfXyhzZWxmKToKICAgICAgICByZXR1cm4gInA9JXMsZj0l
cyxjYWNoZWQ6JWQsYWRkZWQ6JWQscmVtb3ZlZDolZCxpbmRpcmVjdF9yZW1vdmVkOiVkIiAl
IFwKICAgICAgICAgICAgKHNlbGYuX19wcm9jZXNzLm5hbWUsIHNlbGYuX19maWxlLmRldiAr
ICIsIiArIHNlbGYuX19maWxlLmlub2RlLCBcCiAgICAgICAgICAgICAgICAgc2VsZi5jb3Vu
dF9jYWNoZWRfcGFnZSgpLCBzZWxmLmNvdW50X2FkZGVkX3BhZ2UoKSwgXAogICAgICAgICAg
ICAgICAgIHNlbGYuY291bnRfcmVtb3ZlZF9wYWdlKCksIHNlbGYuY291bnRfaW5kaXJlY3Rf
cmVtb3ZlZF9wYWdlKCkpCgpjbGFzcyBGaWxlOgogICAgZGVmIF9faW5pdF9fKHNlbGYsIGRl
diwgaW5vZGUpOgogICAgICAgIHNlbGYuX19kZXYgPSBkZXYKICAgICAgICBzZWxmLl9faW5v
ZGUgPSBpbm9kZQogICAgICAgIHNlbGYuX19jYWNoZWRfcGFnZV9saXN0ID0gW10KICAgICAg
ICBzZWxmLl9fcmVjb3JkcyA9IFtdCiAgICAgICAgc2VsZi5fX3JlbGlhYmxlID0gVHJ1ZQoK
ICAgIGRlZiBnZXRfZGV2KHNlbGYpOgogICAgICAgIHJldHVybiBzZWxmLl9fZGV2CgogICAg
ZGVmIGdldF9pbm9kZShzZWxmKToKICAgICAgICByZXR1cm4gc2VsZi5fX2lub2RlCgogICAg
ZGVmIGFkZF9yZWNvcmQoc2VsZiwgcmVjb3JkKToKICAgICAgICBzZWxmLl9fcmVjb3Jkcy5h
cHBlbmQocmVjb3JkKQoKICAgIGRlZiByZW1vdmVfcGFnZShzZWxmLCBpbmRleCk6CiAgICAg
ICAgaWYgaW5kZXggaW4gc2VsZi5fX2NhY2hlZF9wYWdlX2xpc3Q6CiAgICAgICAgICAgIHNl
bGYuX19jYWNoZWRfcGFnZV9saXN0LnJlbW92ZShpbmRleCkKICAgICAgICBlbHNlOgogICAg
ICAgICAgICBzZWxmLl9fcmVsaWFibGUgPSBGYWxzZQoKICAgIGRlZiBhZGRfcGFnZShzZWxm
LCBpbmRleCk6CiAgICAgICAgaWYgbm90IGluZGV4IGluIHNlbGYuX19jYWNoZWRfcGFnZV9s
aXN0OgogICAgICAgICAgICBzZWxmLl9fY2FjaGVkX3BhZ2VfbGlzdC5hcHBlbmQoaW5kZXgp
CgogICAgZGVmIGNvdW50X2NhY2hlZF9wYWdlKHNlbGYpOgogICAgICAgIHJldHVybiBsZW4o
c2VsZi5fX2NhY2hlZF9wYWdlX2xpc3QpCgpjbGFzcyBQcm9jZXNzOgogICAgZGVmIF9faW5p
dF9fKHNlbGYsIG5hbWUpOgogICAgICAgIHNlbGYuX19uYW1lID0gbmFtZQogICAgICAgIHNl
bGYuX19yZWNvcmRzID0gW10KCiAgICBkZWYgZ2V0X25hbWUoc2VsZik6CiAgICAgICAgcmV0
dXJuIHNlbGYuX19uYW1lCgogICAgZGVmIGFkZF9yZWNvcmQoc2VsZiwgcmVjb3JkKToKICAg
ICAgICBzZWxmLl9fcmVjb3Jkcy5hcHBlbmQocmVjb3JkKQoKICAgIGRlZiBnZXRfcmVjb3Jk
cyhzZWxmKToKICAgICAgICByZXR1cm4gc2VsZi5fX3JlY29yZHMKCiAgICBkZWYgc3VtX2Nh
Y2hlZF9wYWdlKHNlbGYpOgogICAgICAgIHJldHVybiByZWR1Y2UobGFtYmRhIHMsciA6IHMr
ci5jb3VudF9jYWNoZWRfcGFnZSgpLCBzZWxmLl9fcmVjb3JkcywgMCkKCiAgICBkZWYgc3Vt
X2FkZGVkX3BhZ2Uoc2VsZik6CiAgICAgICAgcmV0dXJuIHJlZHVjZShsYW1iZGEgcyxyIDog
cytyLmNvdW50X2FkZGVkX3BhZ2UoKSwgc2VsZi5fX3JlY29yZHMsIDApCgogICAgZGVmIHN1
bV9yZW1vdmVkX3BhZ2Uoc2VsZik6CiAgICAgICAgcmV0dXJuIHJlZHVjZShsYW1iZGEgcyxy
IDogcytyLmNvdW50X3JlbW92ZWRfcGFnZSgpLCBzZWxmLl9fcmVjb3JkcywgMCkKCiAgICBk
ZWYgc3VtX2luZGlyZWN0X3JlbW92ZWRfcGFnZShzZWxmKToKICAgICAgICByZXR1cm4gcmVk
dWNlKGxhbWJkYSBzLHIgOiBzK3IuY291bnRfaW5kaXJlY3RfcmVtb3ZlZF9wYWdlKCksIFwK
ICAgICAgICAgICAgICAgICAgICAgICAgICBzZWxmLl9fcmVjb3JkcywgMCkKCmRlZiBjb252
ZXJ0X3RvX3NpemUobnVtKToKICAgIFBBR0VfU0laRT00CiAgICB1bml0cyA9IFsnSycsICdN
JywgJ0cnLCAnVCddCiAgICBzID0gbnVtICogUEFHRV9TSVpFCiAgICBmb3IgdSBpbiB1bml0
czoKICAgICAgICBzLCBtID0gZGl2bW9kKHMsIDEwMDApCiAgICAgICAgaWYgcyA9PSAwOgog
ICAgICAgICAgICByZXR1cm4gc3RyKG0pICsgdQogICAgcmV0dXJuIHN0cihudW0gKiBQQUdF
X1NJWkUpICsgIksiCgpkZWYgcHJvY2Vzc19ldmVudHMocmVjb3JkZXIsIHNvdXJjZSk6CiAg
ICByZWdleF9ldmVudCA9IFwKICAgICAgICByZS5jb21waWxlKCJccyooW1x3XGQtXSopXHMq
XFtcZCpcXVxzKihbMC05Ll0qKTpccyooXHcqKTpccyooLiopIikKCiAgICBmb3IgbGluZSBp
biBzb3VyY2U6CiAgICAgICAgbSA9IHJlZ2V4X2V2ZW50Lm1hdGNoKGxpbmUpCiAgICAgICAg
aWYgbm90IG06CiAgICAgICAgICAgIGNvbnRpbnVlCiAgICAgICAgKHByb2Nlc3MsIHRpbWUs
IGV2ZW50LCBkYXRhKSA9IG0uZ3JvdXBzKCkKICAgICAgICBpZiBldmVudCA9PSAiZmluZF9n
ZXRfcGFnZSI6CiAgICAgICAgICAgIHJlY29yZGVyLnJlY29yZF9maW5kX2dldF9wYWdlKHBy
b2Nlc3MsIGRhdGEpCiAgICAgICAgZWxpZiBldmVudCA9PSAiYWRkX3RvX3BhZ2VfY2FjaGUi
OgogICAgICAgICAgICByZWNvcmRlci5yZWNvcmRfYWRkX3RvX3BhZ2VfY2FjaGUocHJvY2Vz
cywgZGF0YSkKICAgICAgICBlbGlmIGV2ZW50ID09ICJyZW1vdmVfZnJvbV9wYWdlX2NhY2hl
IiA6CiAgICAgICAgICAgIHJlY29yZGVyLnJlY29yZF9yZW1vdmVfZnJvbV9wYWdlX2NhY2hl
KHByb2Nlc3MsIGRhdGEpCiAgICAgICAgZWxzZToKICAgICAgICAgICAgcHJpbnQgIkludmFs
aWQgZXZlbnQ6ICVzIiAlIGxpbmUKICAgICAgICAgICAgc3lzLmV4aXQoLTEpCgpkZWYgc2hv
d19zdGF0aXN0aWNzKHJlY29yZGVyKToKICAgIHByaW50ICJbZmlsZSBsaXN0XSIKICAgIGZv
ciBmIGluIHJlY29yZGVyLmdldF9maWxlcygpOgogICAgICAgIHByaW50ICIgIGRldjolcywg
aW5vZGU6JXMsIGNhY2hlZDogJXMiICUgKGYuZ2V0X2RldigpLCBmLmdldF9pbm9kZSgpLCBc
CiAgICAgICAgICAgIGNvbnZlcnRfdG9fc2l6ZShmLmNvdW50X2NhY2hlZF9wYWdlKCkpKQog
ICAgcHJpbnQgIltwcm9jZXNzIGxpc3RdIgogICAgZm9yIHAgaW4gcmVjb3JkZXIuZ2V0X3By
b2Nlc3NlcygpOgogICAgICAgIHByaW50ICIgIHByb2Nlc3M6ICVzIiAlIHAuZ2V0X25hbWUo
KSwKICAgICAgICBwcmludCAiKGNhY2hlZDogJXMsIGFkZGVkOiAlcywgcmVtb3ZlZDogJXMs
IGluZGlyZWN0IHJlbW92ZWQ6ICVzKSIgJSBcCiAgICAgICAgICAgIHR1cGxlKG1hcChjb252
ZXJ0X3RvX3NpemUsIFtwLnN1bV9jYWNoZWRfcGFnZSgpLAogICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgcC5zdW1fYWRkZWRfcGFnZSgpLAogICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgcC5zdW1fcmVtb3ZlZF9wYWdlKCksCiAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBwLnN1bV9pbmRpcmVjdF9yZW1v
dmVkX3BhZ2UoKV0pKQogICAgICAgIGZvciByIGluIHAuZ2V0X3JlY29yZHMoKToKICAgICAg
ICAgICAgZiA9IHIuZ2V0X2ZpbGUoKQogICAgICAgICAgICBwcmludCAiICAgIGRldjolcywg
aW5vZGU6JXMsIiAlIChmLmdldF9kZXYoKSwgZi5nZXRfaW5vZGUoKSksCiAgICAgICAgICAg
IHByaW50ICJjYWNoZWQ6JXMsIGFkZGVkOiVzLCByZW1vdmVkOiVzLCBpbmRpcmVjdCByZW1v
dmVkOiVzIiAlIFwKICAgICAgICAgICAgICAgIHR1cGxlKG1hcChjb252ZXJ0X3RvX3NpemUs
IFtyLmNvdW50X2NhY2hlZF9wYWdlKCksCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgci5jb3VudF9hZGRlZF9wYWdlKCksCiAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgci5jb3VudF9yZW1vdmVkX3BhZ2UoKSwKICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICByLmNvdW50X2luZGly
ZWN0X3JlbW92ZWRfcGFnZSgpXSkpCgpkZWYgdXNhZ2UoY21kKToKICAgIHByaW50ICIlcyBb
b3B0aW9uc10uLi4gW2ZpbGVdIiAlIGNtZAogICAgcHJpbnQgIiAgLXAsIC0tcHJvY2Vzcz1u
YW1lICBmaWx0ZXIgYnkgcHJvY2VzcyBuYW1lIgogICAgcHJpbnQgIiAgLWksIC0taW5vZGU9
aW5vZGUgICBmaWx0ZXIgYnkgaW5vZGUiCiAgICBwcmludCAiICAtZCwgLS1kZXY9ZGV2aWNl
ICAgIGZpbHRlciBieSBkZXZpY2UiCiAgICBwcmludCAiICAtaCwgLS1oZWxwICAgICAgICAg
IHByaW50IHRoaXMgaGVscCIKCmRlZiBtYWluKGFyZ3YpOgogICAgdHJ5OgogICAgICAgIG9w
dHMsIGFyZ3MgPSBnZXRvcHQuZ2V0b3B0KGFyZ3ZbMTpdLCAiaHA6aTpkOiIsIFwKICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgWyJoZWxwIiwgInByb2Nlc3M9Iiwg
Imlub2RlPSIsICJkZXY9Il0pCiAgICBleGNlcHQgZ2V0b3B0LkdldG9wdEVycm9yOgogICAg
ICAgIHVzYWdlKHN5cy5hcmd2WzBdKQogICAgICAgIHN5cy5leGl0KC0xKQogICAgKHByb2Nl
c3MsIGRldiwgaW5vZGUpID0gKE5vbmUsIE5vbmUsIE5vbmUpCiAgICBmb3IgbywgYSBpbiBv
cHRzOgogICAgICAgIGlmIG8gaW4gKCItaCIsICItLWhlbHAiKToKICAgICAgICAgICAgdXNh
Z2UoYXJndlswXSkKICAgICAgICAgICAgc3lzLmV4aXQoKQogICAgICAgIGlmIG8gaW4gKCIt
cCIsICItLXByb2Nlc3MiKToKICAgICAgICAgICAgcHJvY2VzcyA9IGEKICAgICAgICBpZiBv
IGluICgiLWQiLCAiLS1kZXYiKToKICAgICAgICAgICAgZGV2ID0gYQogICAgICAgIGlmIG8g
aW4gKCItaSIsICItLWlub2RlIik6CiAgICAgICAgICAgIGlub2RlID0gYQogICAgcmVjb3Jk
ZXIgPSBSZWNvcmRlcigpCiAgICByZWNvcmRlci5zZXRfdGFyZ2V0KHByb2Nlc3MsIGRldiwg
aW5vZGUpCiAgICBwcm9jZXNzX2V2ZW50cyhyZWNvcmRlciwgc3lzLnN0ZGluKQogICAgc2hv
d19zdGF0aXN0aWNzKHJlY29yZGVyKQoKaWYgX19uYW1lX18gPT0gIl9fbWFpbl9fIiA6IG1h
aW4oc3lzLmFyZ3YpCg==
--------------070909050907020509060005--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
