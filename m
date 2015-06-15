Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id D464A6B0070
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:22:21 -0400 (EDT)
Received: by qgf75 with SMTP id 75so29123950qgf.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:22:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e5si13429008qkh.47.2015.06.15.10.22.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 10:22:17 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 5/7] userfaultfd: switch to exclusive wakeup for blocking reads
Date: Mon, 15 Jun 2015 19:22:09 +0200
Message-Id: <1434388931-24487-6-git-send-email-aarcange@redhat.com>
In-Reply-To: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Blocking reads can easily use exclusive wakeups. Poll in theory could
too but there's no poll_wait_exclusive in common code yet.

If a poll() non-exclusive waitqueue is encountered before the
exclusive readblocking waitqueue, then everything will be waken. If a
read exclusive waitqueue is encountered before the poll waitqueue,
only the read will be waken (poll or any other blocked read waiting
will not be waken). In short the improvement is only available if
using pure blocked reads and never poll.

Here a benchmark showing the performance before/after the patch. This
is with the userfaultfd stresstest suite.

Here the relevant points:

wakeall:      48380.184730      task-clock (msec)         #   17.266 CPUs utilized            ( +-  0.47% )
wakeone:      45333.241105      task-clock (msec)         #   17.430 CPUs utilized            ( +-  0.72% )
wakeall:   121,667,046,528      cycles                    #    2.515 GHz                      ( +-  0.56% ) [83.44%]
wakeone:   113,920,663,471      cycles                    #    2.513 GHz                      ( +-  0.66% ) [83.32%]
wakeall:       2.801974022 seconds time elapsed ( +-  0.43% )
wakeone:       2.600912438 seconds time elapsed ( +-  0.02% )

Note the above number refers to the full testsuite and half of the
time it using only poll which remains wake-all, so for pure read
blocking workload the improvement is more significant. And this is
only with 24 uffd threads on only 24 CPUs.

Here the raw userfault numbers referring to those passes only using
blocking reads (never poll mixed in here):

wakeall:mode: rnd racing, userfaults: 206 158 203 194 144 190 102 165 92 80 138 98 76 108 55 64 50 46 27 36 29 8 11 3
wakeone:mode: rnd racing, userfaults: 212 153 144 139 215 116 138 119 118 102 65 93 81 75 63 59 49 44 46 40 19 14 21 6

wakeall:mode: rnd, userfaults: 499 439 546 492 452 403 355 375 318 296 246 230 182 200 194 110 91 125 63 47 41 46 20 11
wakeone:mode: rnd, userfaults: 544 523 490 501 457 449 477 256 471 353 299 323 227 228 222 191 172 79 71 77 65 25 38 0

Full data below.

===
wakeall:

nr_pages: 25584, nr_pages_per_cpu: 1066
bounces: 15, mode: rnd racing ver poll, userfaults: 108 92 116 107 82 97 85 109 88 74 77 56 71 51 41 41 34 24 23 36 18 27 8 3
bounces: 14, mode: racing ver poll, userfaults: 38 26 15 27 27 27 23 17 25 26 17 15 19 12 17 13 3 10 3 5 3 2 4 1
bounces: 13, mode: rnd ver poll, userfaults: 454 456 434 458 394 349 435 370 375 355 364 325 260 168 263 188 159 199 81 113 89 33 36 20
bounces: 12, mode: ver poll, userfaults: 88 59 79 66 52 64 49 40 51 42 29 25 17 24 24 22 19 27 12 4 15 13 9 1
bounces: 11, mode: rnd racing poll, userfaults: 110 128 129 82 102 93 89 62 75 48 66 94 71 40 32 49 29 22 35 24 21 19 10 6
bounces: 10, mode: racing poll, userfaults: 31 28 19 33 23 23 20 17 19 22 14 18 9 8 12 13 14 15 8 2 0 0 0 2
bounces: 9, mode: rnd poll, userfaults: 380 553 558 401 379 351 326 228 283 362 211 223 250 173 189 190 129 133 201 226 143 33 0 0
bounces: 8, mode: poll, userfaults: 75 57 58 46 41 42 46 27 41 52 29 20 27 7 16 6 4 5 7 2 2 1 0 0
bounces: 7, mode: rnd racing ver, userfaults: 192 137 129 114 106 144 89 79 75 54 52 64 77 36 44 39 24 31 27 25 16 8 2 5
bounces: 6, mode: racing ver, userfaults: 28 14 17 26 18 28 12 8 11 30 9 4 21 13 14 13 6 18 19 6 11 2 3 0
bounces: 5, mode: rnd ver, userfaults: 569 477 604 497 515 333 403 368 331 314 328 271 180 223 205 152 125 108 79 29 44 43 12 30
bounces: 4, mode: ver, userfaults: 97 103 90 93 90 43 74 60 58 54 51 41 37 16 31 27 24 27 13 5 5 6 2 1
bounces: 3, mode: rnd racing, userfaults: 241 159 164 169 114 136 133 114 90 69 115 88 111 98 77 64 30 66 23 16 19 12 11 7
bounces: 2, mode: racing, userfaults: 30 34 26 40 20 24 29 38 20 21 17 19 22 13 8 12 7 14 11 5 3 3 1 3
bounces: 1, mode: rnd, userfaults: 595 509 478 371 372 429 397 388 390 269 228 290 205 137 144 157 131 115 148 79 53 46 10 8
bounces: 0, mode:, userfaults: 108 100 83 69 50 64 52 55 52 41 39 27 36 49 28 38 18 30 27 6 8 10 7 2
nr_pages: 25584, nr_pages_per_cpu: 1066
bounces: 15, mode: rnd racing ver poll, userfaults: 167 117 118 92 75 89 112 89 96 103 86 95 78 72 42 72 49 32 73 27 26 20 16 15
bounces: 14, mode: racing ver poll, userfaults: 30 32 18 29 18 24 16 17 11 16 17 11 9 6 17 11 9 8 5 5 7 3 0 0
bounces: 13, mode: rnd ver poll, userfaults: 552 437 468 410 425 432 407 363 388 306 377 298 282 320 289 203 102 132 75 76 97 22 8 5
bounces: 12, mode: ver poll, userfaults: 89 92 92 72 64 68 55 44 61 42 42 28 28 23 26 19 9 6 11 8 1 5 1 1
bounces: 11, mode: rnd racing poll, userfaults: 113 79 101 65 61 67 92 73 52 65 60 46 41 45 27 26 33 21 25 26 3 13 10 5
bounces: 10, mode: racing poll, userfaults: 47 32 43 41 47 26 38 35 32 24 47 24 33 24 33 18 15 15 9 28 13 5 1 0
bounces: 9, mode: rnd poll, userfaults: 487 517 489 376 295 416 294 463 418 438 371 391 246 259 264 263 166 206 181 103 85 23 0 0
bounces: 8, mode: poll, userfaults: 97 95 82 99 65 67 60 61 40 60 60 41 40 40 24 26 22 33 10 12 8 4 4 0
bounces: 7, mode: rnd racing ver, userfaults: 171 127 127 114 137 101 106 103 72 90 69 61 39 44 29 37 29 36 21 33 2 9 1 1
bounces: 6, mode: racing ver, userfaults: 23 13 20 13 10 6 11 10 9 4 5 8 7 5 9 11 7 15 8 3 2 1 3 2
bounces: 5, mode: rnd ver, userfaults: 450 496 410 398 503 372 342 298 306 294 221 184 191 156 80 102 108 74 69 29 63 36 23 38
bounces: 4, mode: ver, userfaults: 126 106 125 82 100 69 96 75 51 55 46 49 61 41 43 49 29 25 30 25 12 0 0 0
bounces: 3, mode: rnd racing, userfaults: 142 126 124 104 105 104 122 69 77 92 52 52 77 40 37 35 30 19 13 19 11 12 11 2
bounces: 2, mode: racing, userfaults: 24 22 28 18 6 21 18 27 20 19 18 21 7 15 15 14 14 7 3 4 4 2 3 5
bounces: 1, mode: rnd, userfaults: 448 451 388 433 355 283 304 421 359 260 251 277 239 276 242 167 89 114 144 65 29 27 23 7
bounces: 0, mode:, userfaults: 66 71 53 62 43 57 30 31 37 25 38 8 29 10 20 23 13 8 6 10 2 3 1 0
nr_pages: 25584, nr_pages_per_cpu: 1066
bounces: 15, mode: rnd racing ver poll, userfaults: 117 80 92 70 114 88 86 65 82 67 72 55 68 48 49 24 48 31 21 32 27 22 5 12
bounces: 14, mode: racing ver poll, userfaults: 19 28 26 23 20 21 24 28 17 30 32 14 10 13 8 16 17 3 18 15 7 3 8 0
bounces: 13, mode: rnd ver poll, userfaults: 402 390 379 330 449 441 416 436 469 249 376 327 321 332 318 380 297 139 110 105 41 29 19 0
bounces: 12, mode: ver poll, userfaults: 111 80 79 75 78 70 71 55 42 37 32 48 41 24 41 27 24 30 16 21 24 9 24 1
bounces: 11, mode: rnd racing poll, userfaults: 114 85 129 95 96 93 80 66 44 80 55 62 65 65 76 34 54 48 22 41 44 8 21 5
bounces: 10, mode: racing poll, userfaults: 19 14 17 9 8 10 15 11 15 7 4 3 9 8 7 2 9 4 5 6 2 1 9 0
bounces: 9, mode: rnd poll, userfaults: 425 362 355 359 334 327 336 341 286 224 204 216 197 126 162 97 93 181 91 134 63 63 29 33
bounces: 8, mode: poll, userfaults: 82 53 65 43 48 48 31 25 28 25 41 13 10 12 7 13 6 3 4 4 3 1 1 1
bounces: 7, mode: rnd racing ver, userfaults: 146 143 118 142 124 152 123 103 97 99 94 72 100 51 59 52 40 38 19 32 13 7 4 6
bounces: 6, mode: racing ver, userfaults: 24 31 22 24 14 18 19 36 24 22 36 22 19 10 2 0 6 2 4 2 1 1 4 2
bounces: 5, mode: rnd ver, userfaults: 532 478 425 541 433 355 278 360 267 267 257 229 157 174 174 136 163 69 107 79 37 39 36 23
bounces: 4, mode: ver, userfaults: 110 122 74 69 102 61 81 71 43 65 44 29 26 10 26 23 9 11 18 5 15 2 3 3
bounces: 3, mode: rnd racing, userfaults: 206 158 203 194 144 190 102 165 92 80 138 98 76 108 55 64 50 46 27 36 29 8 11 3
bounces: 2, mode: racing, userfaults: 66 32 30 25 28 24 19 21 35 23 23 12 25 14 11 39 12 4 6 3 1 0 0 0
bounces: 1, mode: rnd, userfaults: 499 439 546 492 452 403 355 375 318 296 246 230 182 200 194 110 91 125 63 47 41 46 20 11
bounces: 0, mode:, userfaults: 77 84 103 69 56 40 31 36 48 41 30 45 34 20 15 17 20 4 7 4 4 3 1 1

 Performance counter stats for './userfaultfd 100 16' (3 runs):

      48380.184730      task-clock (msec)         #   17.266 CPUs utilized            ( +-  0.47% )
           193,120      context-switches          #    0.004 M/sec                    ( +-  0.42% )
            29,131      cpu-migrations            #    0.602 K/sec                    ( +-  0.31% )
           124,534      page-faults               #    0.003 M/sec                    ( +-  0.73% )
   121,667,046,528      cycles                    #    2.515 GHz                      ( +-  0.56% ) [83.44%]
    88,715,214,401      stalled-cycles-frontend   #   72.92% frontend cycles idle     ( +-  0.74% ) [83.59%]
    38,649,861,616      stalled-cycles-backend    #   31.77% backend  cycles idle     ( +-  1.06% ) [67.25%]
    63,497,981,871      instructions              #    0.52  insns per cycle
                                                  #    1.40  stalled cycles per insn  ( +-  0.21% ) [83.86%]
    12,494,182,458      branches                  #  258.250 M/sec                    ( +-  0.25% ) [83.55%]
        57,700,648      branch-misses             #    0.46% of all branches          ( +-  2.64% ) [83.41%]

       2.801974022 seconds time elapsed                                          ( +-  0.43% )

wakeone:

nr_pages: 25584, nr_pages_per_cpu: 1066
bounces: 15, mode: rnd racing ver poll, userfaults: 125 94 71 95 73 81 84 69 61 57 60 72 57 39 38 55 28 24 26 8 11 21 5 1
bounces: 14, mode: racing ver poll, userfaults: 24 16 8 12 30 21 16 22 22 19 14 10 11 6 8 6 10 9 6 7 3 8 3 3
bounces: 13, mode: rnd ver poll, userfaults: 548 353 409 354 423 425 387 316 350 282 379 203 210 214 228 180 192 187 166 75 37 45 42 0
bounces: 12, mode: ver poll, userfaults: 91 75 67 65 52 68 44 43 58 29 27 29 20 27 13 11 12 9 5 1 2 2 0 1
bounces: 11, mode: rnd racing poll, userfaults: 142 94 130 117 128 91 96 84 59 53 88 55 53 74 22 52 32 24 22 41 34 12 4 6
bounces: 10, mode: racing poll, userfaults: 22 29 23 22 26 20 14 21 15 11 23 20 23 16 4 15 15 11 6 11 5 6 0 4
bounces: 9, mode: rnd poll, userfaults: 333 402 361 374 345 344 297 338 208 307 222 171 196 208 134 137 97 87 191 133 120 68 45 3
bounces: 8, mode: poll, userfaults: 84 71 67 56 57 55 41 39 41 27 33 46 33 26 13 20 14 11 9 4 1 7 1 0
bounces: 7, mode: rnd racing ver, userfaults: 152 127 123 133 121 126 93 124 99 80 81 67 59 67 51 51 46 34 27 17 8 7 9 7
bounces: 6, mode: racing ver, userfaults: 36 34 20 17 15 33 18 20 13 19 31 17 19 9 16 22 10 21 6 5 6 1 1 2
bounces: 5, mode: rnd ver, userfaults: 534 448 498 402 400 454 396 357 287 262 266 281 239 233 235 258 230 100 106 95 82 55 29 3
bounces: 4, mode: ver, userfaults: 106 114 91 79 83 88 54 33 63 56 78 41 40 42 35 16 26 38 26 14 12 27 11 8
bounces: 3, mode: rnd racing, userfaults: 191 147 186 124 131 136 147 110 95 104 88 85 103 56 56 74 43 42 29 47 30 7 9 14
bounces: 2, mode: racing, userfaults: 34 48 28 45 46 39 64 39 32 22 20 16 32 37 18 44 36 14 20 11 18 11 18 1
bounces: 1, mode: rnd, userfaults: 568 488 434 492 473 343 295 271 364 329 306 240 299 330 212 240 163 151 144 88 60 52 8 5
bounces: 0, mode:, userfaults: 112 103 67 47 56 57 32 60 55 46 41 51 64 31 25 35 15 17 25 8 7 10 0 1
nr_pages: 25584, nr_pages_per_cpu: 1066
bounces: 15, mode: rnd racing ver poll, userfaults: 120 184 139 91 102 89 92 97 100 67 127 92 69 53 53 64 55 51 39 13 12 11 6 4
bounces: 14, mode: racing ver poll, userfaults: 52 21 23 39 22 19 9 20 12 14 13 22 8 16 21 13 10 12 8 12 2 3 4 0
bounces: 13, mode: rnd ver poll, userfaults: 509 453 392 469 467 413 422 434 384 227 298 197 318 236 213 273 210 320 144 62 58 35 3 0
bounces: 12, mode: ver poll, userfaults: 82 85 64 67 68 45 61 32 29 35 32 46 22 17 29 22 7 18 4 15 8 8 10 4
bounces: 11, mode: rnd racing poll, userfaults: 170 110 107 116 135 99 91 88 65 78 53 61 47 47 64 46 33 31 20 15 7 8 6 3
bounces: 10, mode: racing poll, userfaults: 34 20 23 22 19 19 19 24 22 24 13 27 26 23 8 7 14 8 6 7 6 9 5 2
bounces: 9, mode: rnd poll, userfaults: 522 482 455 502 361 606 363 365 259 302 325 449 333 424 308 470 124 142 147 129 28 2 0 0
bounces: 8, mode: poll, userfaults: 112 90 86 71 71 68 63 65 48 33 27 33 23 18 30 16 26 25 13 16 10 8 3 0
bounces: 7, mode: rnd racing ver, userfaults: 211 147 125 114 150 108 121 136 117 86 96 80 60 56 58 49 45 36 51 27 19 31 7 3
bounces: 6, mode: racing ver, userfaults: 35 35 42 12 21 27 20 22 22 43 23 23 27 27 23 24 35 21 19 12 5 11 14 13
bounces: 5, mode: rnd ver, userfaults: 413 473 383 326 282 300 349 240 283 223 220 208 248 197 196 155 136 68 74 62 32 24 41 33
bounces: 4, mode: ver, userfaults: 129 85 78 77 59 49 61 35 56 31 24 32 25 16 20 15 24 8 19 4 10 8 12 3
bounces: 3, mode: rnd racing, userfaults: 207 125 161 147 158 156 103 116 125 89 113 78 75 39 51 49 46 18 27 18 14 20 13 2
bounces: 2, mode: racing, userfaults: 15 30 21 12 17 14 11 15 9 19 12 12 9 14 17 13 11 7 4 13 2 6 6 9
bounces: 1, mode: rnd, userfaults: 567 489 490 463 526 485 365 465 394 416 362 281 263 212 164 143 129 141 122 42 65 30 37 25
bounces: 0, mode:, userfaults: 96 80 91 66 74 71 51 43 56 47 45 49 24 28 18 43 20 6 15 29 2 27 10 11
nr_pages: 25584, nr_pages_per_cpu: 1066
bounces: 15, mode: rnd racing ver poll, userfaults: 141 97 67 113 101 90 98 87 76 66 79 46 53 53 43 34 51 26 25 25 22 3 4 2
bounces: 14, mode: racing ver poll, userfaults: 19 16 12 19 17 19 13 10 15 11 16 5 7 13 9 8 4 0 1 3 3 0 2 1
bounces: 13, mode: rnd ver poll, userfaults: 439 369 337 357 417 306 286 328 376 342 242 190 321 181 166 223 304 165 124 133 45 99 0 0
bounces: 12, mode: ver poll, userfaults: 130 86 69 80 81 60 70 60 100 86 62 66 66 41 63 54 30 30 15 10 15 3 1 0
bounces: 11, mode: rnd racing poll, userfaults: 141 105 103 95 109 82 61 56 100 72 75 60 68 60 35 34 21 43 11 18 19 4 7 12
bounces: 10, mode: racing poll, userfaults: 39 24 22 25 19 20 20 10 20 6 16 11 14 9 8 8 10 5 7 3 3 3 4 0
bounces: 9, mode: rnd poll, userfaults: 527 589 542 524 599 525 329 478 417 373 351 412 317 392 385 237 186 126 166 106 33 38 0 0
bounces: 8, mode: poll, userfaults: 77 65 62 54 60 48 41 29 42 31 20 23 14 18 11 11 11 8 6 1 1 2 0 0
bounces: 7, mode: rnd racing ver, userfaults: 195 90 96 159 99 89 107 81 65 61 57 47 71 45 46 25 26 24 34 27 17 15 13 4
bounces: 6, mode: racing ver, userfaults: 40 19 29 20 21 13 23 11 12 16 12 17 16 17 13 12 17 7 23 5 4 7 2 2
bounces: 5, mode: rnd ver, userfaults: 420 455 283 460 361 416 270 274 304 152 354 296 252 154 167 196 148 180 129 67 117 46 24 11
bounces: 4, mode: ver, userfaults: 116 79 58 60 62 45 44 58 43 53 31 33 43 33 18 16 4 13 7 2 9 6 5 0
bounces: 3, mode: rnd racing, userfaults: 212 153 144 139 215 116 138 119 118 102 65 93 81 75 63 59 49 44 46 40 19 14 21 6
bounces: 2, mode: racing, userfaults: 45 30 42 26 28 39 32 31 20 36 43 20 26 11 12 11 22 14 11 4 20 13 0 3
bounces: 1, mode: rnd, userfaults: 544 523 490 501 457 449 477 256 471 353 299 323 227 228 222 191 172 79 71 77 65 25 38 0
bounces: 0, mode:, userfaults: 117 82 83 81 77 61 46 50 33 66 46 28 18 34 35 20 8 8 19 12 12 18 2 3

 Performance counter stats for './userfaultfd 100 16' (3 runs):

      45333.241105      task-clock (msec)         #   17.430 CPUs utilized            ( +-  0.72% )
           190,388      context-switches          #    0.004 M/sec                    ( +-  0.85% )
            26,983      cpu-migrations            #    0.595 K/sec                    ( +-  1.02% )
           135,232      page-faults               #    0.003 M/sec                    ( +-  1.46% )
   113,920,663,471      cycles                    #    2.513 GHz                      ( +-  0.66% ) [83.32%]
    83,823,483,951      stalled-cycles-frontend   #   73.58% frontend cycles idle     ( +-  0.65% ) [83.41%]
    35,786,661,114      stalled-cycles-backend    #   31.41% backend  cycles idle     ( +-  0.86% ) [67.29%]
    59,478,650,192      instructions              #    0.52  insns per cycle
                                                  #    1.41  stalled cycles per insn  ( +-  0.65% ) [84.04%]
    11,635,219,658      branches                  #  256.660 M/sec                    ( +-  0.71% ) [83.69%]
        59,203,898      branch-misses             #    0.51% of all branches          ( +-  2.03% ) [83.54%]

       2.600912438 seconds time elapsed                                          ( +-  0.02% )

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f9e11ec..a66c4be 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -501,6 +501,7 @@ static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 	struct userfaultfd_ctx *ctx = file->private_data;
 	unsigned int ret;
 
+	/* FIXME: poll_wait_exclusive doesn't exist yet in common code */
 	poll_wait(file, &ctx->fd_wqh, wait);
 
 	switch (ctx->state) {
@@ -542,7 +543,7 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 
 	/* always take the fd_wqh lock before the fault_pending_wqh lock */
 	spin_lock(&ctx->fd_wqh.lock);
-	__add_wait_queue(&ctx->fd_wqh, &wait);
+	__add_wait_queue_exclusive(&ctx->fd_wqh, &wait);
 	for (;;) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		spin_lock(&ctx->fault_pending_wqh.lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
