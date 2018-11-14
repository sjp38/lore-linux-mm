Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 872276B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 09:53:01 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id d196so38163586qkb.6
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 06:53:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a2si5538780qkj.36.2018.11.14.06.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 06:52:59 -0800 (PST)
Date: Wed, 14 Nov 2018 22:52:50 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181114145250.GE2653@MiWiFi-R3L-srv>
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
 <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
 <20181114090134.GG23419@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114090134.GG23419@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

On 11/14/18 at 10:01am, Michal Hocko wrote:
> I have seen an issue when the migration cannot make a forward progress
> because of a glibc page with a reference count bumping up and down. Most
> probable explanation is the faultaround code. I am working on this and
> will post a patch soon. In any case the migration should converge and if
> it doesn't do then there is a bug lurking somewhere.
> 
> Failing on ENOMEM is a questionable thing. I haven't seen that happening
> wildly but if it is a case then I wouldn't be opposed.

Applied your debugging patches, it helps a lot to printing message.

Below is the dmesg log about the migrating failure. It can't pass
migrate_pages() and loop forever.

[  +0.083841] migrating pfn 10fff7d0 failed 
[  +0.000005] page:ffffea043ffdf400 count:208 mapcount:201 mapping:ffff888dff4bdda8 index:0x2
[  +0.012689] xfs_address_space_operations [xfs] 
[  +0.000030] name:"stress" 
[  +0.004556] flags: 0x5fffffc0000004(uptodate)
[  +0.007339] raw: 005fffffc0000004 ffffc900000e3d80 ffffc900000e3d80 ffff888dff4bdda8
[  +0.009488] raw: 0000000000000002 0000000000000000 000000cb000000c8 ffff888e7353d000
[  +0.007726] page->mem_cgroup:ffff888e7353d000
[  +0.084538] migrating pfn 10fff7d0 failed 
[  +0.000006] page:ffffea043ffdf400 count:210 mapcount:201 mapping:ffff888dff4bdda8 index:0x2
[  +0.012798] xfs_address_space_operations [xfs] 
[  +0.000034] name:"stress" 
[  +0.004524] flags: 0x5fffffc0000004(uptodate)
[  +0.007068] raw: 005fffffc0000004 ffffc900000e3d80 ffffc900000e3d80 ffff888dff4bdda8
[  +0.009359] raw: 0000000000000002 0000000000000000 000000cb000000c8 ffff888e7353d000
[  +0.007728] page->mem_cgroup:ffff888e7353d000

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This is numactl -H, the last memory block of node1 can't be migrated.

[root@~]# numactl -H
available: 8 nodes (0-7)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161
node 0 size: 58793 MB
node 0 free: 50374 MB
node 1 cpus: 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179
node 1 size: 2048 MB
node 1 free: 0 MB
node 2 cpus: 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197
node 2 size: 65536 MB
node 2 free: 60102 MB
node 3 cpus: 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215
node 3 size: 65536 MB
node 3 free: 61237 MB
node 4 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233
node 4 size: 65536 MB
node 4 free: 63057 MB
node 5 cpus: 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251
node 5 size: 65536 MB
node 5 free: 62507 MB
node 6 cpus: 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269
node 6 size: 65536 MB
node 6 free: 62688 MB
node 7 cpus: 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287
node 7 size: 65536 MB
node 7 free: 61775 MB
node distances:
node   0   1   2   3   4   5   6   7 
  0:  10  21  31  21  41  41  51  51 
  1:  21  10  21  31  41  41  51  51 
  2:  31  21  10  21  51  51  41  41 
  3:  21  31  21  10  51  51  41  41 
  4:  41  41  51  51  10  21  31  21 
  5:  41  41  51  51  21  10  21  31 
  6:  51  51  41  41  31  21  10  21 
  7:  51  51  41  41  21  31  21  10

> 
> > You mentioned memory pressure, if our host is under memory pressure we
> > can easily trigger running into an endless loop there, because we
> > basically ignore -ENOMEM e.g. when we cannot get a page to migrate some
> > memory to be offlined. I assume this is the case here.
> > do_migrate_range() could be the bad boy if it keeps failing forever and
> > we keep retrying.
> 
> My hotplug debugging patches [1] should help to tell us.
> 
> [1] http://lkml.kernel.org/r/20181107101830.17405-1-mhocko@kernel.org
> -- 
> Michal Hocko
> SUSE Labs
